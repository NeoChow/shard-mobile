/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import VMLKit

class VMLConfigSpec: QuickSpec {
    override func spec() {
        it("changes the default") {
            let oldDefault = VMLConfig.default
            let newConfig = VMLConfig.Builder().build()
            
            expect(oldDefault) == VMLConfig.default
            newConfig.makeDefault()
            expect(newConfig) == VMLConfig.default
            expect(oldDefault) != VMLConfig.default
        }
        
        it("has correct defaults") {
            expect(VMLConfig.default.shadowViews.keys).to(contain("flexbox"))
            expect(VMLConfig.default.shadowViews.keys).to(contain("image"))
            expect(VMLConfig.default.shadowViews.keys).to(contain("text"))
            expect(VMLConfig.default.shadowViews.keys).to(contain("solid-color"))
        }
    }
}
