//
//  NetworkAuthManager.swift
//  PPPC Utility
//
//  MIT License
//
//  Copyright (c) 2022 Jamf Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

enum AuthError: Error {
    case invalidToken
    case invalidUsernamePassword
}

/// This actor ensures that only one token refresh occurs at the same time.
actor NetworkAuthManager {
    private let username: String
    private let password: String

    private var currentToken: Token?
    private var refreshTask: Task<Token, Error>?

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    func validToken(networking: Networking) async throws -> Token {
        if let task = refreshTask {
            // A refresh is already running; we'll use those results when ready.
            return try await task.value
        }

        if let token = currentToken,
           token.isValid {
            return token
        }

        return try await refreshToken(networking: networking)
    }

    func refreshToken(networking: Networking) async throws -> Token {
        if let task = refreshTask {
            // A refresh is already running; we'll use those results when ready.
            return try await task.value
        }

        // Initiate a refresh.
        let task = Task { () throws -> Token in
            defer { refreshTask = nil }

            let newToken = try await networking.getBearerToken()

            currentToken = newToken

            return newToken
        }

        refreshTask = task

        return try await task.value
    }

    /// Properly encodes the username and password for use in Basic authentication.
    ///
    /// This doesn't mutate any state and only accesses `let` constants so it doesn't need to be actor isolated.
    /// - Returns: The encoded data string for use with Basic Auth.
    nonisolated func basicAuthString() throws -> String {
        guard let result = "\(username):\(password)".data(using: .utf8)?.base64EncodedString(),
              !result.isEmpty else {
            throw AuthError.invalidUsernamePassword
        }
        return result
    }
}

struct Token: Decodable {
    let value: String
    let expireTime: String

    var isValid: Bool {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: expireTime) {
            return date > Date()
        }
        return false
    }

    enum CodingKeys: String, CodingKey {
        case value = "token"
        case expireTime = "expires"
    }
}
