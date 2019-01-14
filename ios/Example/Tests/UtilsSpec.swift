/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import ShardKit

class UtilsSpec: QuickSpec {
    override func spec() {
        it("should parse color") {
            expect(try! UIColor(hex: "#f00")).to(equal(UIColor.red))
            expect(try! UIColor(hex: "#ff0000")).to(equal(UIColor.red))
            expect(try! UIColor(hex: "#ffff0000")).to(equal(UIColor.red))
        }
        
        it("should convert string to ShardColor") {
            let color = try! JsonValue.String("#F00").asColor()
            
            expect(color.default).to(equal(UIColor.red))
            expect(color.pressed).to(beNil())
        }
        
        it("should convert object to ShardColor") {
            let color = try! JsonValue.Object([
                "default": JsonValue.String("#F00"),
                "pressed": JsonValue.String("#00F")]
            ).asColor()
            
            expect(color.default).to(equal(UIColor.red))
            expect(color.pressed).to(equal(UIColor.blue))
        }
    }
}
