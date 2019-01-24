/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import ShardKit

class ImageViewImplSpec: QuickSpec {
    override func spec() {
        let viewimpl = ImageViewImpl(ShardContext())
        
        it("should set src") {
            try! viewimpl.setProp(key: "src", value: JsonValue.String("https://shardlib.com"))
            expect(viewimpl.src).to(equal(URL(string: "https://shardlib.com")))
        }
        
        it("should set content mode to cover") {
            try! viewimpl.setProp(key: "content-mode", value: JsonValue.String("cover"))
            expect(viewimpl.contentMode).to(equal(UIView.ContentMode.scaleAspectFill))
        }
        
        it("should set content mode to contain") {
            try! viewimpl.setProp(key: "content-mode", value: JsonValue.String("contain"))
            expect(viewimpl.contentMode).to(equal(UIView.ContentMode.scaleAspectFit))
        }
        
        it("should set content mode to center") {
            try! viewimpl.setProp(key: "content-mode", value: JsonValue.String("center"))
            expect(viewimpl.contentMode).to(equal(UIView.ContentMode.center))
        }
    }
}
