/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

internal class BaseViewImpl: VMLViewImpl {
    internal var backgroundColor = UIColor.clear
    internal var borderColor = UIColor.clear
    internal var borderWidth = Float(0)
    internal var borderRadius = Float(0)
    
    func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        fatalError("Subclass must override")
    }
    
    func createView() -> UIView {
        fatalError("Subclass must override")
    }
    
    func setProp(key: String, value: JsonValue) {
        switch key {
        case "background-color":
            self.backgroundColor = try! UIColor(hex: try! value.asString())
        case "border-color":
            self.borderColor = try! UIColor(hex: try! value.asString())
        case "border-width":
            self.borderWidth = try! value.asObject().asDimension()
        case "border-radius":
            switch value {
            case let .String(value) where value == "max": self.borderRadius = Float.infinity
            case let .Object(value): self.borderRadius = try! value.asDimension()
            default: self.borderRadius = 0
            }
            
        default: ()
        }
    }
    
    func bindView(_ view: UIView) {
        view.backgroundColor = backgroundColor
        view.layer.borderColor = borderColor.cgColor
        view.layer.borderWidth = CGFloat(borderWidth)
        view.layer.cornerRadius = borderRadius.isInfinite ? min(view.frame.width, view.frame.height) / 2 : CGFloat(borderRadius)
    }
}
