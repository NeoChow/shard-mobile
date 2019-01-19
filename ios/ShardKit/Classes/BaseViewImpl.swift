/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public enum ShardControlState: String {
    case Default = "default"
    case Pressed = "pressed"
}

class BaseViewImpl: ShardViewImpl {
    internal let context: ShardContext
    internal lazy var tapGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        gesture.minimumPressDuration = 0
        return gesture
    }()
    
    internal var backgroundColor = ShardColor(default: UIColor.clear, pressed: nil)
    internal var borderColor = UIColor.clear
    internal var borderWidth = Float(0)
    internal var borderRadius = Float(0)
    internal var clickHandler: () -> () = {}
    internal var view: UIView? = nil
    
    var delegate: ShardViewDelegate?
    
    var state: ShardControlState = .Default {
        didSet {
            switch state {
            case .Pressed:
                self.view?.backgroundColor = self.backgroundColor.pressed ?? self.backgroundColor.default
                break
            default:
                self.view?.backgroundColor = self.backgroundColor.default
                break
            }
        }
    }
    
    init(_ context: ShardContext) {
        self.context = context
    }
    
    func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        fatalError("Subclass must override")
    }
    
    func createView() -> UIView {
        fatalError("Subclass must override")
    }
    
    func setProp(key: String, value: JsonValue) {
        switch key {
        case "background-color":
            self.backgroundColor = try! value.asColor()
        case "border-color":
            self.borderColor = try! value.asColor().default
        case "border-width":
            self.borderWidth = try! value.asObject().asDimension()
        case "border-radius":
            switch value {
            case let .String(value) where value == "max": self.borderRadius = Float.infinity
            case let .Object(value): self.borderRadius = try! value.asDimension()
            default: self.borderRadius = 0
            }
        case "on-click":
            let value = try! value.asObject()
            let action = try! value["action"]!.asString()
            self.clickHandler = { self.context.dispatch(action: action, value: value["value"]) }
            
        default: ()
        }
    }
    
    func bindView(_ view: UIView) {
        view.clipsToBounds = true
        view.backgroundColor = backgroundColor.default
        view.layer.borderColor = borderColor.cgColor
        view.layer.borderWidth = CGFloat(borderWidth)
        view.layer.cornerRadius = borderRadius.isInfinite ? min(view.frame.width, view.frame.height) / 2 : CGFloat(borderRadius)
        view.removeGestureRecognizer(self.tapGestureRecognizer)
        view.addGestureRecognizer(self.tapGestureRecognizer)
        
        self.view = view
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            self.delegate?.setState(.Default)
            self.clickHandler()
        case .began:
            self.delegate?.setState(.Pressed)
        default: ()
        }
    }
}
