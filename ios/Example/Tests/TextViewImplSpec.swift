/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import VMLKit

class TextViewImplSpec: QuickSpec {
    override func spec() {
        let viewimpl = TextViewImpl()
        
        it("should set text align to start") {
            viewimpl.setProp(key: "text-align", value: JsonValue.String("start"))
            expect(viewimpl.textAlignment).to(equal(NSTextAlignment.left))
        }
        
        it("should set text align to end") {
            viewimpl.setProp(key: "text-align", value: JsonValue.String("end"))
            expect(viewimpl.textAlignment).to(equal(NSTextAlignment.right))
        }
        
        it("should set text align to center") {
            viewimpl.setProp(key: "text-align", value: JsonValue.String("center"))
            expect(viewimpl.textAlignment).to(equal(NSTextAlignment.center))
        }
        
        it("should set max lines") {
            viewimpl.setProp(key: "max-lines", value: JsonValue.Number(1))
            expect(viewimpl.numberOfLines).to(equal(1))
        }
        
        it("should set line height") {
            viewimpl.setProp(key: "line-height", value: JsonValue.Object([
                "unit": JsonValue.String("points"),
                "value": JsonValue.Number(10)
            ]))
            expect(viewimpl.lineHeightMultiple).to(equal(10))
        }
        
        it("should set simple span") {
            viewimpl.setProp(key: "span", value: JsonValue.Object([
                "text": JsonValue.String("Hello")
                ]))
            expect(viewimpl.text.string).to(equal("Hello"))
        }
        
        it("should set complex span") {
            viewimpl.setProp(key: "span", value: JsonValue.Object([
                "text": JsonValue.Array([
                    JsonValue.Object(["text": JsonValue.String("Hello")]),
                    JsonValue.Object(["text": JsonValue.String(" ")]),
                    JsonValue.Object(["text": JsonValue.String("world")])
                ])
            ]))
            expect(viewimpl.text.string).to(equal("Hello world"))
        }
    }
}
