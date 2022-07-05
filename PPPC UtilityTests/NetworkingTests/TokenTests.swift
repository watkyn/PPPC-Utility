//
//  TokenTests.swift
//  PPPC UtilityTests
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
import XCTest

@testable import PPPC_Utility

class TokenTests: XCTestCase {
    func testPastIsNotValid() {
        // given
        let token = Token(value: "abc", expireTime: "2021-06-22T22:05:58.81Z")

        // when
        let valid = token.isValid

        // then
        XCTAssertFalse(valid)
    }

    func testFutureIsValid() {
        // given
        let token = Token(value: "abc", expireTime: "2750-06-22T22:05:58.81Z")

        // when
        let valid = token.isValid

        // then
        XCTAssertTrue(valid)
    }
}
