/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import yoga

private let YogaMeasureFunc: YGMeasureFunc = { (node, width, widthMode, height, heightMode) -> YGSize in
    let view: VMLShadowView = Unmanaged.fromOpaque(UnsafeRawPointer(YGNodeGetContext(node))).takeUnretainedValue()
    
    let size = view.sizeThatFits(
        CGSize(
            width: widthMode == .undefined ? .greatestFiniteMagnitude : CGFloat(width),
            height: heightMode == .undefined ? .greatestFiniteMagnitude : CGFloat(height)))
    
    let measuredWidth: Float
    let measuredHeight: Float
    
    switch widthMode {
    case .undefined: measuredWidth = Float(size.width)
    case .exactly: measuredWidth = width
    case .atMost: measuredWidth = min(Float(size.width), width)
    }
    
    switch heightMode {
    case .undefined: measuredHeight = Float(size.height)
    case .exactly: measuredHeight = height
    case .atMost: measuredHeight = min(Float(size.height), height)
    }
    
    return YGSize(width: measuredWidth, height: measuredHeight)
}

class VMLYogaShadowView : VMLShadowViewParent {
    private var baseProps: VMLBaseProps? = nil
    
    static let config: YGConfigRef = {
        let config = YGConfigNew()!
        YGConfigSetUseWebDefaults(config, true)
        YGConfigSetPointScaleFactor(config, Float(UIScreen.main.scale))
        return config
    }()
    
    internal var node: YGNodeRef = YGNodeNewWithConfig(config)
    internal var children: [(YGNodeRef, VMLShadowView)] = []
    
    override func setProps(_ props: [String: JSON]) throws {
        self.baseProps = try VMLBaseProps(props)
    
        try props.get("flex-direction") {
            switch $0 {
            case .String(let value) where value == "row": YGNodeStyleSetFlexDirection(node, .row)
            case .String(let value) where value == "column": YGNodeStyleSetFlexDirection(node, .column)
            case .Null: ()
            case let value: throw "Unexpected value for flex-direction: \(value)"
            }
        }
        
        try props.get("flex-wrap") {
            switch $0 {
            case .String(let value) where value == "nowrap": YGNodeStyleSetFlexWrap(node, .noWrap)
            case .String(let value) where value == "wrap": YGNodeStyleSetFlexWrap(node, .wrap)
            case .String(let value) where value == "wrap-reverse": YGNodeStyleSetFlexWrap(node, .wrapReverse)
            case .Null: ()
            case let value: throw "Unexpected value for flex-wrap: \(value)"
            }
        }
        
        try props.get("align-items") {
            switch $0 {
            case .String(let value) where value == "stretch": YGNodeStyleSetAlignItems(node, .stretch)
            case .String(let value) where value == "flex-start": YGNodeStyleSetAlignItems(node, .flexStart)
            case .String(let value) where value == "flex-end": YGNodeStyleSetAlignItems(node, .flexEnd)
            case .String(let value) where value == "center": YGNodeStyleSetAlignItems(node, .center)
            case .Null: ()
            case let value: throw "Unexpected value for align-items: \(value)"
            }
        }
        
        try props.get("align-content") {
            switch $0 {
            case .String(let value) where value == "stretch": YGNodeStyleSetAlignContent(node, .stretch)
            case .String(let value) where value == "flex-start": YGNodeStyleSetAlignContent(node, .flexStart)
            case .String(let value) where value == "flex-end": YGNodeStyleSetAlignContent(node, .flexEnd)
            case .String(let value) where value == "space-between": YGNodeStyleSetAlignContent(node, .spaceBetween)
            case .String(let value) where value == "space-around":YGNodeStyleSetAlignContent(node, .spaceAround)
            case .String(let value) where value == "center": YGNodeStyleSetAlignContent(node, .center)
            case .Null: ()
            case let value: throw "Unexpected value for align-content: \(value)"
            }
        }
        
        try props.get("justify-content") {
            switch $0 {
            case .String(let value) where value == "flex-start": YGNodeStyleSetJustifyContent(node, .flexStart)
            case .String(let value) where value == "flex-end": YGNodeStyleSetJustifyContent(node, .flexEnd)
            case .String(let value) where value == "space-between": YGNodeStyleSetJustifyContent(node, .spaceBetween)
            case .String(let value) where value == "space-around": YGNodeStyleSetJustifyContent(node, .spaceAround)
            case .String(let value) where value == "center": YGNodeStyleSetJustifyContent(node, .center)
            case .Null: ()
            case let value: throw "Unexpected value for justify-content: \(value)"
            }
        }
        
        let setPadding = { (prop: String, edge: YGEdge) in
            try props.get(prop) {
                switch $0 {
                case .Object(let padding):
                    switch try padding.asYGValue() {
                    case let value where value.unit == .point: YGNodeStyleSetPadding(self.node, edge, value.value)
                    case let value where value.unit == .percent: YGNodeStyleSetPaddingPercent(self.node, edge, value.value)
                    default: fatalError()
                    }
                case .Null: ()
                case let value: throw "Unexpected value for \(prop): \(value)"
                }
            }
        };
        
        try setPadding("padding", .all)
        try setPadding("padding-start", .start)
        try setPadding("padding-end", .end)
        try setPadding("padding-top", .top)
        try setPadding("padding-bottom", .bottom)
        
        let children: [JSON] = try props.get("children") {
            switch $0 {
            case .Array(let value): return value
            case let value: throw "Unexpected value for children: \(value)"
            }
        }
        
        self.children = []
        YGNodeRemoveAllChildren(node)

        for child in children {
            let child = try child.asObject()
            
            let kind: String = try child.get("kind") {
                switch $0 {
                case .String(let value): return value
                case let value: throw "Unexpected value for kind: \(value)"
                }
            };
            
            let props: [String: JSON] = try child.get("props") {
                switch $0 {
                case .Object(let value): return value
                case let value: throw "Unexpected value for props: \(value)"
                }
            };
            
            let childShadowView = try ctx.createShadowView(kind: kind, parent: self)
            try childShadowView.setProps(props)

            let childNode: YGNodeRef = {
                if let childShadowView = childShadowView as? VMLYogaShadowView {
                    return childShadowView.node
                } else {
                    let node = YGNodeNewWithConfig(VMLYogaShadowView.config)!
                    YGNodeSetContext(node, Unmanaged.passUnretained(childShadowView).toOpaque())
                    YGNodeSetMeasureFunc(node, YogaMeasureFunc)
                    return node
                }
            }()
            
            let layout: [String: JSON] = try child.get("layout") {
                switch $0 {
                case .Object(let value): return value
                case .Null: return [:]
                case let value: throw "Unexpected value for layout: \(value)"
                }
            }
            
            try layout.get("position") {
                switch $0 {
                case .String(let value) where value == "relative": YGNodeStyleSetPositionType(childNode, .relative)
                case .String(let value) where value == "absolute": YGNodeStyleSetPositionType(childNode, .absolute)
                case .Null: ()
                case let value: throw "Unexpected value for position: \(value)"
                }
            }
            
            let setPosition = { (prop: String, edge: YGEdge) in
                try layout.get(prop) {
                    switch $0 {
                    case .Object(let position):
                        switch try position.asYGValue() {
                        case let value where value.unit == .point: YGNodeStyleSetPosition(childNode, edge, value.value)
                        case let value where value.unit == .percent: YGNodeStyleSetPositionPercent(childNode, edge, value.value)
                        default: fatalError()
                        }
                    case .Null: ()
                    case let value: throw "Unexpected value for \(prop): \(value)"
                    }
                }
            };
            
            try setPosition("start", .start)
            try setPosition("end", .end)
            try setPosition("top", .top)
            try setPosition("bottom", .bottom)
            
            let setMargin = { (prop: String, edge: YGEdge) in
                try layout.get(prop) {
                    switch $0 {
                    case .Object(let margin):
                        switch try margin.asYGValue() {
                        case let value where value.unit == .point: YGNodeStyleSetMargin(childNode, edge, value.value)
                        case let value where value.unit == .percent: YGNodeStyleSetMarginPercent(childNode, edge, value.value)
                        default: fatalError()
                        }
                    case .String(let value) where value == "auto": YGNodeStyleSetMarginAuto(childNode, edge)
                    case .Null: ()
                    case let value: throw "Unexpected value for \(prop): \(value)"
                    }
                }
            };
            
            try setMargin("margin", .all)
            try setMargin("margin-start", .start)
            try setMargin("margin-end", .end)
            try setMargin("margin-top", .top)
            try setMargin("margin-bottom", .bottom)
            
            try layout.get("width") {
                switch $0 {
                case .Object(let value):
                    switch try value.asYGValue() {
                    case let value where value.unit == .auto: YGNodeStyleSetWidthAuto(childNode)
                    case let value where value.unit == .point: YGNodeStyleSetWidth(childNode, value.value)
                    case let value where value.unit == .percent: YGNodeStyleSetWidthPercent(childNode, value.value)
                    default: ()
                    }
                case .Null: ()
                case let value: throw "Unexpected value for width: \(value)"
                }
            }
            
            try layout.get("min-width") {
                switch $0 {
                case .Object(let value):
                    switch try value.asYGValue() {
                    case let value where value.unit == .point: YGNodeStyleSetMinWidth(childNode, value.value)
                    case let value where value.unit == .percent: YGNodeStyleSetMinWidthPercent(childNode, value.value)
                    default: ()
                    }
                case .Null: ()
                case let value: throw "Unexpected value for width: \(value)"
                }
            }
            
            try layout.get("max-width") {
                switch $0 {
                case .Object(let value):
                    switch try value.asYGValue() {
                    case let value where value.unit == .point: YGNodeStyleSetMaxWidth(childNode, value.value)
                    case let value where value.unit == .percent: YGNodeStyleSetMaxWidthPercent(childNode, value.value)
                    default: ()
                    }
                case .Null: ()
                case let value: throw "Unexpected value for width: \(value)"
                }
            }
            
            try layout.get("height") {
                switch $0 {
                case .Object(let value):
                    switch try value.asYGValue() {
                    case let value where value.unit == .auto: YGNodeStyleSetHeightAuto(childNode)
                    case let value where value.unit == .point: YGNodeStyleSetHeight(childNode, value.value)
                    case let value where value.unit == .percent: YGNodeStyleSetHeightPercent(childNode, value.value)
                    default: ()
                    }
                case .Null: ()
                case let value: throw "Unexpected value for width: \(value)"
                }
            }
            
            try layout.get("min-height") {
                switch $0 {
                case .Object(let value):
                    switch try value.asYGValue() {
                    case let value where value.unit == .point: YGNodeStyleSetMinHeight(childNode, value.value)
                    case let value where value.unit == .percent: YGNodeStyleSetMinHeightPercent(childNode, value.value)
                    default: ()
                    }
                case .Null: ()
                case let value: throw "Unexpected value for width: \(value)"
                }
            }
            
            try layout.get("max-height") {
                switch $0 {
                case .Object(let value):
                    switch try value.asYGValue() {
                    case let value where value.unit == .point: YGNodeStyleSetMaxHeight(childNode, value.value)
                    case let value where value.unit == .percent: YGNodeStyleSetMaxHeightPercent(childNode, value.value)
                    default: ()
                    }
                case .Null: ()
                case let value: throw "Unexpected value for width: \(value)"
                }
            }
            
            try layout.get("flex-grow") {
                switch $0 {
                case .Number(let value): YGNodeStyleSetFlexGrow(childNode, value)
                case .Null: ()
                case let value: throw "Unexpected value for flex-grow: \(value)"
                }
            }
            
            try layout.get("flex-shrink") {
                switch $0 {
                case .Number(let value): YGNodeStyleSetFlexShrink(childNode, value)
                case .Null: ()
                case let value: throw "Unexpected value for flex-shrink: \(value)"
                }
            }
            
            try layout.get("flex-basis") {
                switch $0 {
                case .Object(let value):
                    switch try value.asYGValue() {
                    case let value where value.unit == .auto: YGNodeStyleSetFlexBasisAuto(childNode)
                    case let value where value.unit == .point: YGNodeStyleSetFlexBasis(childNode, value.value)
                    case let value where value.unit == .percent: YGNodeStyleSetFlexBasisPercent(childNode, value.value)
                    default: ()
                    }
                case .Null: ()
                case let value: throw "Unexpected value for width: \(value)"
                }
            }
            
            try layout.get("align-self") {
                switch $0 {
                case .String(let value) where value == "auto": YGNodeStyleSetAlignSelf(childNode, .auto)
                case .String(let value) where value == "stretch": YGNodeStyleSetAlignSelf(childNode, .stretch)
                case .String(let value) where value == "flex-start": YGNodeStyleSetAlignSelf(childNode, .flexStart)
                case .String(let value) where value == "flex-end": YGNodeStyleSetAlignSelf(childNode, .flexEnd)
                case .String(let value) where value == "center": YGNodeStyleSetAlignSelf(childNode, .center)
                case .Null: ()
                case let value: throw "Unexpected value for align-items: \(value)"
                }
            }
            
            try layout.get("aspect-ratio") {
                switch $0 {
                case .Number(let value): YGNodeStyleSetAspectRatio(childNode, value)
                case .Null: ()
                case let value: throw "Unexpected value for aspect-ratio: \(value)"
                }
            }
            
            YGNodeInsertChild(node, childNode, UInt32(self.children.count))
            self.children.append((childNode, childShadowView))
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        YGNodeCalculateLayout(
            node,
            size.width == .greatestFiniteMagnitude
                ? YGUndefined
                : Float(size.width),
            size.height == .greatestFiniteMagnitude
                ? YGUndefined
                : Float(size.height),
            YGDirection.LTR)

        return CGSize(width: CGFloat(YGNodeLayoutGetWidth(node)), height: CGFloat(YGNodeLayoutGetHeight(node)))
    }
    
    override func layoutChildren() {
        // Only run layout calculation from root
        if YGNodeGetOwner(node) == nil {
            YGNodeCalculateLayout(node, Float(self.frame.size.width), Float(self.frame.size.height), YGDirection.LTR)
        }
        
        for (childNode, child) in children {
            child.setFrame(CGRect(
                x: CGFloat(YGNodeLayoutGetLeft(childNode)),
                y: CGFloat(YGNodeLayoutGetTop(childNode)),
                width: CGFloat(YGNodeLayoutGetWidth(childNode)),
                height: CGFloat(YGNodeLayoutGetHeight(childNode))))
            
            
            if let child = child as? VMLShadowViewParent {
                child.layoutChildren()
            }
        }
    }
    
    override func setNeedsLayout(_ dirtyChild: VMLShadowView) {
        self.parent?.setNeedsLayout(self)
        
        for (childNode, child) in children {
            if child === dirtyChild {
                if YGNodeGetMeasureFunc(childNode) != nil {
                    YGNodeMarkDirty(childNode)
                    break
                }
            }
        }
    }
    
    override func getView() -> VMLView {
        let view = VMLBaseView()
        view.frame = frame
        
        for (_, childShadowView) in children {
            view.addSubview(childShadowView.getView())
        }
        
        baseProps?.apply(ctx: ctx, view: view)
        return view
    }
}
