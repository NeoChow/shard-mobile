/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import ShardKit

class BaseViewImplSpec: QuickSpec {
    override func spec() {
        let viewimpl = BaseViewImpl(ShardContext())
        
        it("should set background color") {
            try! viewimpl.setProp(key: "background-color", value: JsonValue.String("#f00"))
            expect(viewimpl.backgroundColor.default).to(equal(UIColor.red))
        }
        
        it("should set clickable background color") {
            try! viewimpl.setProp(key: "background-color", value: JsonValue.Object([
                "default": JsonValue.String("#F00"),
                "pressed": JsonValue.String("#00F")]
            ))
            expect(viewimpl.backgroundColor.default).to(equal(UIColor.red))
            expect(viewimpl.backgroundColor.pressed).to(equal(UIColor.blue))
        }

        it("should set border color") {
            try! viewimpl.setProp(key: "border-color", value: JsonValue.String("#f00"))
            expect(viewimpl.borderColor).to(equal(UIColor.red))
        }

        it("should set border width") {
            try! viewimpl.setProp(key: "border-width", value: JsonValue.Object([
                "unit": JsonValue.String("points"),
                "value": JsonValue.Number(10)
            ]))
            expect(viewimpl.borderWidth).to(equal(10))
        }

        it("should set border radius") {
            try! viewimpl.setProp(key: "border-radius", value: JsonValue.Object([
                "unit": JsonValue.String("points"),
                "value": JsonValue.Number(10)
            ]))
            expect(viewimpl.borderRadius).to(equal(10))
        }

        it("should set border radius to max") {
            try! viewimpl.setProp(key: "border-radius", value: JsonValue.String("max"))
            expect(viewimpl.borderRadius).to(equal(Float.infinity))
        }
    }
}
