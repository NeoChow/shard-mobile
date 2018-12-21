/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import VMLKit

class VMLImageShadowViewSpec: QuickSpec {
    override func spec() {
        let ctx = VMLContext(config: VMLConfig.default, root: VMLRootView())
        
        it("should fail if no src is set") {
            let shadowView = VMLImageShadowView(ctx, nil)
            
            do {
                try shadowView.setProps([:])
                fail("Expected exception")
            } catch { }
        }
        
        it("should set content-mode") {
            let shadowView = VMLImageShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "src": JSON.String("https://visly.app"),
                "content-mode": JSON.String("cover")
            ])
            
            let image = (shadowView.getView() as! VMLViewWrapper<UIImageView>).wrapping
            expect(image.contentMode) == UIView.ContentMode.scaleAspectFill
        }
        
        it("should have correct defaults") {
            let shadowView = VMLImageShadowView(ctx, nil)
            
            try! shadowView.setProps(["src": JSON.String("https://visly.app")])
            
            let image = (shadowView.getView() as! VMLViewWrapper<UIImageView>).wrapping
            expect(image.contentMode) == UIView.ContentMode.center
        }
    }
}
