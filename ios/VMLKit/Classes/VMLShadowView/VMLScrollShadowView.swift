/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

private enum Direction {
    case vertical
    case horizontal
}

class VMLScrollShadowView : VMLShadowViewParent {
    private var baseProps: VMLBaseProps? = nil
    private var direction: Direction = .vertical
    private var contentInset: UIEdgeInsets = .zero
    private var contentOffset: CGPoint = .zero
    private var content: VMLShadowView? = nil
    private var contentSize: CGSize = .zero
    
    override func setProps(_ props: [String: JSON]) throws {
        self.baseProps = try VMLBaseProps(props)

        self.direction = try props.get("direction") {
            switch $0 {
            case .String(let value) where value == "vertical": return .vertical
            case .String(let value) where value == "horizontal": return .horizontal
            case .Null: return .vertical
            case let value: throw "Unexpected value for direction: \(value)"
            }
        }
        
        (self.contentInset, self.contentOffset) = try props.get("content-inset") {
            switch $0 {
            case .Object(let value):
                let inset = CGFloat(try value.asDimension())
                if direction == .vertical {
                    return (UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0), CGPoint(x: 0, y: -inset))
                } else {
                    return (UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset), CGPoint(x: -inset, y: 0))
                }
            case .Null: return (UIEdgeInsets.zero, CGPoint.zero)
            case let value: throw "Unexpected value for content-inset: \(value)"
            }
        }
        
        self.content = try props.get("content") {
            switch $0 {
            case .Object(let content):
                let kind: String = try content.get("kind") {
                    switch $0 {
                    case .String(let value): return value
                    case let value: throw "Unexpected value for kind: \(value)"
                    }
                }
                
                let props: [String: JSON] = try content.get("props") {
                    switch $0 {
                    case .Object(let value): return value
                    case let value: throw "Unexpected value for props: \(value)"
                    }
                }
                
                let content = try ctx.createShadowView(kind: kind, parent: self)
                try content.setProps(props)
                return content
                
            case let value: throw "Unexpected value for content: \(value)"
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize  {
        if let content = self.content {
            return content.sizeThatFits(CGSize(
                width: direction == .vertical ? size.width : .greatestFiniteMagnitude,
                height: direction == .horizontal ? size.height : .greatestFiniteMagnitude))
        } else {
            return size
        }
    }
    
    override func layoutChildren() {
        if let content = self.content {
            self.contentSize = content.sizeThatFits(CGSize(
                width: direction == .vertical ? frame.width : .greatestFiniteMagnitude,
                height: direction == .horizontal ? frame.height : .greatestFiniteMagnitude))
            
            content.setFrame(CGRect(
                x: 0,
                y: 0,
                width: direction == .vertical ? frame.width : contentSize.width,
                height: direction == .horizontal ? frame.height : contentSize.height))
            
            if let content = content as? VMLShadowViewParent {
                content.layoutChildren()
            }
        }
    }
    
    override func setNeedsLayout(_ dirtyChild: VMLShadowView) {
        self.parent?.setNeedsLayout(self)
    }

    override func getView() -> VMLView  {
        let view = UIScrollView()
        view.alwaysBounceVertical = self.direction == .vertical
        view.alwaysBounceHorizontal = self.direction == .horizontal
        view.contentInset = self.contentInset
        view.contentOffset = self.contentOffset
        view.contentSize = self.contentSize
        
        if let content = self.content {
            view.addSubview(content.getView())
        }
        
        let wrapper = VMLViewWrapper(wrapping: view)
        wrapper.frame = frame
        baseProps?.apply(ctx: ctx, view: wrapper)
        return wrapper
    }
}
