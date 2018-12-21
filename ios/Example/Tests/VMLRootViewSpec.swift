/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import VMLKit

class VMLRootViewSpec: QuickSpec {
    override func spec() {
        it("should dispatch event") {
            let root = VMLRootView()
            let context = VMLContext(config: VMLConfig.default, root: root)
            
            var actionPerformed = false
            root.on("perform-action") { _ in actionPerformed = true }
            context.dispatchEvent(type: "perform-action", data: [:])
            expect(actionPerformed) == true
        }
        
        it("should remove event handler") {
            let root = VMLRootView()
            let context = VMLContext(config: VMLConfig.default, root: root)
            
            var actionPerformed = false
            root.on("perform-action") { _ in actionPerformed = true }
            root.on("perform-action", nil)
            context.dispatchEvent(type: "perform-action", data: [:])
            expect(actionPerformed) == false
        }
    }
}
