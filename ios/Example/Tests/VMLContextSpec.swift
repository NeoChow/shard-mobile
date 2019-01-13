/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import VMLKit

class TestVMLContextDelegate: VMLContextDelegate {
    var action: String? = nil
    var value: JsonValue? = nil
    
    func onActionDispatched(action: String, value: JsonValue?) {
        self.action = action
        self.value = value
    }
}

class VMLContextSpec: QuickSpec {
    override func spec() {
        it("should dispatch action with nil value") {
            let context = VMLContext()
            let delegate = TestVMLContextDelegate()
            context.delegate = delegate
            context.dispatch(action: "click", value: nil)
            expect(delegate.action).to(equal("click"))
            expect(delegate.value).to(beNil())
        }
        
        it("should dispatch action with some value") {
            let context = VMLContext()
            let delegate = TestVMLContextDelegate()
            context.delegate = delegate
            context.dispatch(action: "click", value: JsonValue.String("hello"))
            expect(delegate.action).to(equal("click"))
            expect(try! delegate.value?.asString()).to(equal("hello"))
        }
    }
}
