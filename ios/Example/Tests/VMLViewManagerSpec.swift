/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import VMLKit

class VMLViewManagerSpec: QuickSpec {
    override func spec() {
        it("has correct defaults") {
            expect(VMLViewManager.shared.implFactories.count).to(equal(5))
            expect(VMLViewManager.shared.implFactories.keys).to(contain("flexbox"))
            expect(VMLViewManager.shared.implFactories.keys).to(contain("image"))
            expect(VMLViewManager.shared.implFactories.keys).to(contain("text"))
            expect(VMLViewManager.shared.implFactories.keys).to(contain("scroll"))
            expect(VMLViewManager.shared.implFactories.keys).to(contain("solid-color"))
        }
    }
}
