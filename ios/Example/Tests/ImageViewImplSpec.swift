/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import VMLKit

class ImageViewImplSpec: QuickSpec {
    override func spec() {
        let viewimpl = ImageViewImpl()
        
        it("should set src") {
            viewimpl.setProp(key: "src", value: JsonValue.String("https://visly.app"))
            expect(viewimpl.src).to(equal(URL(string: "https://visly.app")))
        }
        
        it("should set content mode to cover") {
            viewimpl.setProp(key: "content-mode", value: JsonValue.String("cover"))
            expect(viewimpl.contentMode).to(equal(UIView.ContentMode.scaleAspectFill))
        }
        
        it("should set content mode to contain") {
            viewimpl.setProp(key: "content-mode", value: JsonValue.String("contain"))
            expect(viewimpl.contentMode).to(equal(UIView.ContentMode.scaleAspectFit))
        }
        
        it("should set content mode to center") {
            viewimpl.setProp(key: "content-mode", value: JsonValue.String("center"))
            expect(viewimpl.contentMode).to(equal(UIView.ContentMode.center))
        }
    }
}
