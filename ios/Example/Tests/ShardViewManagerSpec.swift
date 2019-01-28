/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import ShardKit

class ShardViewManagerSpec: QuickSpec {
    class NetworkSessionMock: NetworkSession {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        func loadData(from url: URL, onComplete: @escaping (Data?, URLResponse?, Error?) -> Void) {
            onComplete(data, response, error)
        }
    }
    
    override func spec() {
        it("has correct defaults") {
            expect(ShardViewManager.shared.implFactories.count).to(equal(5))
            expect(ShardViewManager.shared.implFactories.keys).to(contain("flexbox"))
            expect(ShardViewManager.shared.implFactories.keys).to(contain("image"))
            expect(ShardViewManager.shared.implFactories.keys).to(contain("text"))
            expect(ShardViewManager.shared.implFactories.keys).to(contain("scroll"))
            expect(ShardViewManager.shared.implFactories.keys).to(contain("solid-color"))
        }
        
        it("loadUrl should complete with failure if a network error occurs") {
            let mockUrl = URL(string: "url")
            
            let sessionMock = NetworkSessionMock()
            let mockError = NSError(
                domain: "",
                code: -1004,
                userInfo: [:]
            )
            sessionMock.error = mockError
            ShardViewManager.shared.session = sessionMock
            
            ShardViewManager.shared.loadUrl(url: mockUrl!) {
                switch $0 {
                case .Failure: ()
                default: fail("Expected failure")
                }
            }
        }
        
        it("loadUrl should complete with failure if status code is not 200") {
            let mockUrl = URL(string: "url")
            
            let sessionMock = NetworkSessionMock()
            let mockResponse = HTTPURLResponse(
                url: mockUrl!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: [:]
            )
            sessionMock.response = mockResponse
            ShardViewManager.shared.session = sessionMock
            
            ShardViewManager.shared.loadUrl(url: mockUrl!) {
                switch $0 {
                case .Failure(let error):
                    if let shardError = error as? ShardError {
                        expect(shardError.type).to(equal(ShardError.ShardErrorType.HttpStatusCodeError))
                    } else {
                        fail("Expected error of type ShardError")
                    }
                default: fail("Expected failure")
                }
            }
        }
        
        it("loadUrl should complete with failure if response type is unknown") {
            let mockUrl = URL(string: "url")
            
            let sessionMock = NetworkSessionMock()
            let mockResponse = URLResponse(
                url: mockUrl!,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            )
            sessionMock.response = mockResponse
            ShardViewManager.shared.session = sessionMock
            
            ShardViewManager.shared.loadUrl(url: mockUrl!) {
                switch $0 {
                case .Failure(let error):
                    if let shardError = error as? ShardError {
                        expect(shardError.type).to(equal(ShardError.ShardErrorType.UnknownResponseError))
                    } else {
                        fail("Expected error of type ShardError")
                    }
                default: fail("Expected failure")
                }
            }
        }
    }
}
