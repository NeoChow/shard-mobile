/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import ShardKit

class TextViewImplSpec: QuickSpec {
    override func spec() {
        let viewimpl = TextViewImpl(ShardContext(), [:])
        
        it("should set text align to start") {
            try! viewimpl.setProp(key: "text-align", value: JsonValue.String("start"))
            expect(viewimpl.textAlignment).to(equal(NSTextAlignment.left))
        }
        
        it("should set text align to end") {
            try! viewimpl.setProp(key: "text-align", value: JsonValue.String("end"))
            expect(viewimpl.textAlignment).to(equal(NSTextAlignment.right))
        }
        
        it("should set text align to center") {
            try! viewimpl.setProp(key: "text-align", value: JsonValue.String("center"))
            expect(viewimpl.textAlignment).to(equal(NSTextAlignment.center))
        }
        
        it("should set max lines") {
            try! viewimpl.setProp(key: "max-lines", value: JsonValue.Number(1))
            expect(viewimpl.numberOfLines).to(equal(1))
        }
        
        it("should set line height") {
            try! viewimpl.setProp(key: "line-height", value: JsonValue.Object([
                "unit": JsonValue.String("points"),
                "value": JsonValue.Number(10)
                ]))
            expect(viewimpl.lineHeightMultiple).to(equal(10))
        }
        
        it("should set simple span") {
            try! viewimpl.setProp(key: "span", value: JsonValue.Object([
                "text": JsonValue.String("Hello")
                ]))
            expect(viewimpl.text.string).to(equal("Hello"))
        }
        
        it("should set complex span") {
            try! viewimpl.setProp(key: "span", value: JsonValue.Object([
                "text": JsonValue.Array([
                    JsonValue.Object(["text": JsonValue.String("Hello")]),
                    JsonValue.Object(["text": JsonValue.String(" ")]),
                    JsonValue.Object(["text": JsonValue.String("world!")])
                    ])
                ]))
            expect(viewimpl.text.string).to(equal("Hello world!"))
        }
        
        it("should set simple tap handler") {
            try! viewimpl.setProp(key: "span", value: JsonValue.Object([
                "text": JsonValue.String("Hello world!"),
                "on-click": JsonValue.Object(["action": JsonValue.String("example-action")])
                ]))
            
            expect(viewimpl.tapEvents.count).to(equal(1))
        }
        
        it("should set complex tap handler") {
            try! viewimpl.setProp(key: "span", value: JsonValue.Object([
                "text": JsonValue.Array([
                    JsonValue.Object([
                        "text": JsonValue.String("Hello"),
                        "on-click": JsonValue.Object(["action": JsonValue.String("example-action")])
                        ]),
                    JsonValue.Object(["text": JsonValue.String(" ")]),
                    JsonValue.Object([
                        "text": JsonValue.String("world!"),
                        "on-click": JsonValue.Object(["action": JsonValue.String("example-action")])
                        ]),
                    ])
                ]))
            
            let result = viewimpl.tapEvents
            
            expect(result.count).to(equal(2))
            
            expect(result[0].range.location).to(equal(0))
            expect(result[0].range.length).to(equal("Hello".count))
            
            expect(result[1].range.location).to(equal("Hello ".count))
            expect(result[1].range.length).to(equal("world!".count))
        }
        
        it("should set tap handler on nested text") {
            try! viewimpl.setProp(key: "span", value: JsonValue.Object([
                "text": JsonValue.Array([
                    JsonValue.Object(["text": JsonValue.String("Hello")]),
                    JsonValue.Object(["text": JsonValue.String(" ")]),
                    JsonValue.Object([
                        "text": JsonValue.Array([
                            JsonValue.Object(["text": JsonValue.String("world")]),
                            JsonValue.Object(["text": JsonValue.String("!")]),
                            ]),
                        "on-click": JsonValue.Object(["action": JsonValue.String("example-action")])
                        ])
                    ])
                ]))
            
            let result = viewimpl.tapEvents
            
            expect(result.count).to(equal(1))
            
            expect(result[0].range.location).to(equal("Hello ".count))
            expect(result[0].range.length).to(equal("world!".count))
        }
        
        it("should use registered font") {
            func registeredFont(_ size: CGFloat) -> UIFont {
                return UIFont(name: "Helvetica", size: size)!
            }
            let viewimpl = TextViewImpl(ShardContext(), ["Registered-Font":registeredFont])
            
            try! viewimpl.setProp(key: "span", value: JsonValue.Object([
                "text": JsonValue.String("Hello world!"),
                "font-family": JsonValue.String("Registered-Font")
                ]))
            
            let font = viewimpl.text.attribute(.font, at: 0, effectiveRange: nil) as! UIFont
            expect(font.fontName).to(equal("Helvetica"))
        }
        
        it("should throw error if used font is unregistered") {
            let viewimpl = TextViewImpl(ShardContext(), [:])
            
            var errorResult: Error?
            
            do {
                try viewimpl.setProp(key: "span", value: JsonValue.Object([
                    "text": JsonValue.String("Hello world!"),
                    "font-family": JsonValue.String("Registered-Font")
                    ]))
            } catch {
                errorResult = error
            }
            
            expect(errorResult).notTo(beNil())
        }
    }
}
