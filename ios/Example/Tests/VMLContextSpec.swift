/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import VMLKit

class VMLContextSpec: QuickSpec {
    override func spec() {
        let root = VMLRootView()
        let context = VMLContext(config: VMLConfig.default, root: root)

        it("should create flexbox without throwing") {
            let _ = try! context.createShadowView(kind: "flexbox", parent: nil)
        }

        it("should create image without throwing") {
            let _ = try! context.createShadowView(kind: "image", parent: nil)
        }

        it("should create text without throwing") {
            let _ = try! context.createShadowView(kind: "text", parent: nil)
        }

        it("should create solid-color without throwing") {
            let _ = try! context.createShadowView(kind: "solid-color", parent: nil)
        }

        it("should register new view") {
            let config = VMLConfig.Builder().addView(kind: "test", shadowView: { VMLShadowView($0, $1) }).build()
            let context = VMLContext(config: config, root: root)
            let _ = try! context.createShadowView(kind: "test", parent: nil)
        }

        it("should throw on unkown kind") {
            do {
                let _ = try context.createShadowView(kind: "hello", parent: nil)
                fail("Expected to throw on unkown kind")
            } catch { }
        }
    }
}
