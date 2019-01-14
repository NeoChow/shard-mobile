/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import ShardKit

class ScrollViewImplSpec: QuickSpec {
    override func spec() {
        let viewimpl = ScrollViewImpl(ShardContext())
        
        it("should set direction vertical") {
            viewimpl.setProp(key: "direction", value: JsonValue.String("vertical"))
            expect(viewimpl.direction).to(equal(Direction.vertical))
        }
        
        it("should set direction horizontal") {
            viewimpl.setProp(key: "direction", value: JsonValue.String("horizontal"))
            expect(viewimpl.direction).to(equal(Direction.horizontal))
        }
        
        it("should set content inset") {
            viewimpl.setProp(key: "content-inset", value: JsonValue.Object([
                "unit": JsonValue.String("points"),
                "value": JsonValue.Number(10)
            ]))
            expect(viewimpl.contentInset).to(equal(10))
        }
    }
}
