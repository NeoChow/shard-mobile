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
    internal var content: ShardRoot? = nil
    
    override func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        if let content = content {
            return content.measure(width: width, height: height)
        } else {
            return CGSize(width: width ?? 0, height: height ?? 0)
        }
    }
    
    override func setProp(key: String, value: JsonValue) throws {
        try super.setProp(key: key, value: value)
        
        switch key {
        case "direction":
            switch value {
            case .String(let value) where value == "vertical": self.direction = .vertical
            case .String(let value) where value == "horizontal": self.direction = .horizontal
            default: return self.direction = .vertical
            }
        case "content-inset": self.contentInset = try value.asObject().asDimension()
        case "content":
            let result = ShardViewManager.shared.loadJson(value)
            switch(result) {
            case .Success(let content):
                self.content = content
            case .Failure(let error):
                throw error
            }
        default: ()
        }
    }
    
    override func createView() -> UIView {
        let scroll = UIScrollView()
        let contentRoot = ShardRootView()
        scroll.addSubview(contentRoot)
        return scroll
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
            let contentRoot = view.subviews[0] as! ShardRootView
            
            let size = content.layout(
                width: self.direction == .vertical ? view.frame.width : nil,
                height: self.direction == .horizontal ? view.frame.height : nil)
            
            contentRoot.frame = CGRect(origin: .zero, size: size)
            view.contentSize = size
            contentRoot.setRoot(content)
        }
    }
}
