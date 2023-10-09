//
//  Token.swift
//  PPPC Utility
//
//  MIT License
//
//  Copyright (c) 2023 Jamf Software
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

/// Network authentication token for Jamf Pro connection.
///
/// Decodes network response for authentication tokens from Jamf Pro for both the newer OAuth client credentials flow
/// and the older basic-auth-based flow.
struct Token: Decodable {
    let value: String
	let expiresAt: Date?

    var isValid: Bool {
		if let expiration = expiresAt {
			return expiration > Date()
		}

		return true
    }

	enum OAuthTokenCodingKeys: String, CodingKey {
		case value = "access_token"
		case expire = "expires_in"
	}

	enum BasicAuthCodingKeys: String, CodingKey {
        case value = "token"
        case expireTime = "expires"
    }

	init(from decoder: Decoder) throws {
		// First try to decode with oauth client credentials token response
		let container = try decoder.container(keyedBy: OAuthTokenCodingKeys.self)
		let possibleValue = try? container.decode(String.self, forKey: .value)
		if let value = possibleValue {
			self.value = value
			let expireIn = try container.decode(Double.self, forKey: .expire)
			self.expiresAt = Date().addingTimeInterval(expireIn)
			return
		}

		// If that fails try to decode with basic auth token response
		let container1 = try decoder.container(keyedBy: BasicAuthCodingKeys.self)
		self.value = try container1.decode(String.self, forKey: .value)
		let expireTime = try container1.decode(String.self, forKey: .expireTime)

		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		self.expiresAt = formatter.date(from: expireTime)
	}

	init(value: String, expiresAt: Date) {
		self.value = value
		self.expiresAt = expiresAt
	}
}
