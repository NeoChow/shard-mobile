/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

internal enum Direction {
    case vertical
    case horizontal
}

internal class ScrollViewImpl: BaseViewImpl {
    internal var direction: Direction = .vertical
    internal var contentInset = Float(0)
    internal var content: VMLRoot? = nil
    
    override func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        if let content = content {
            return content.sizeThatFits(width: width, height: height)
        } else {
            return CGSize(width: width ?? 0, height: height ?? 0)
        }
    }
    
    override func setProp(key: String, value: JsonValue) {
        super.setProp(key: key, value: value)
        
        switch key {
        case "direction":
            switch value {
            case .String(let value) where value == "vertical": self.direction = .vertical
            case .String(let value) where value == "horizontal": self.direction = .horizontal
            default: return self.direction = .vertical
            }
        case "content-inset": self.contentInset = try! value.asObject().asDimension()
        case "content": self.content = VMLViewManager.shared.loadJson(value)
        default: ()
        }
    }
    
    override func createView() -> UIView {
        return UIScrollView()
    }
    
    override func bindView(_ view: UIView) {
        super.bindView(view)
        
        let view = view as! UIScrollView
        view.alwaysBounceVertical = self.direction == .vertical
        view.alwaysBounceHorizontal = self.direction == .horizontal
        
        let inset = CGFloat(self.contentInset)
        if direction == .vertical {
            view.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
            view.contentOffset = CGPoint(x: 0, y: -inset)
        } else {
            view.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            view.contentOffset = CGPoint(x: -inset, y: 0)
        }
        
        if let content = self.content {
            content.sizeToFit(
                width: self.direction == .vertical ? view.frame.width : nil,
                height: self.direction == .horizontal ? view.frame.height : nil)
            view.addSubview(content.view)
            view.contentSize = content.view.frame.size
        }
    }
}
