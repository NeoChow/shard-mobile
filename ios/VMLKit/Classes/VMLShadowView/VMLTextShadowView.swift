/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

let systemFont = UIFont.systemFont(ofSize: 10);

class VMLTextShadowView : VMLShadowView {
    private var baseProps: VMLBaseProps? = nil
    
    private lazy var view: VMLLabel = {
        let label = VMLLabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    private var text: NSAttributedString = NSAttributedString()
    private var numberOfLines: Int = -1
    private var textAlignment: NSTextAlignment = .left
    
    func attributedString(from props: [String: JSON]) throws -> NSAttributedString {
        let string: NSMutableAttributedString = try props.get("text") {
            switch $0 {
            case .String(let value):
                return NSMutableAttributedString(string: value)
            case .Array(let value):
                let parts = try value.map({ try attributedString(from: $0.asObject()) })
                return NSMutableAttributedString(attributedString: parts.reduce(NSAttributedString(), { $0 + $1 }))
            case let value: throw "Unexpected value for text: \(value)"
            }
        }
        
        let family: String = try props.get("font-family") {
            switch $0 {
            case .String(let value): return value
            case .Null: return systemFont.familyName
            case let value: throw "Unexpected value for font-family: \(value)"
            }
        }
        
        let italic: Bool = try props.get("font-style") {
            switch $0 {
            case .String(let value) where value == "normal": return false
            case .String(let value) where value == "italic": return true
            case .Null: return false
            case let value: throw "Unexpected value for font-style: \(value)"
            }
        }
        
        let size: CGFloat? = try props.get("font-size") {
            switch $0 {
            case .Object(let value): return CGFloat(try value.asDimension())
            case .Null: return nil
            case let value: throw "Unexpected value for font-size: \(value)"
            }
        }
        
        let weight: UIFont.Weight? = try props.get("font-weight") {
            switch $0 {
            case .String(let value) where value == "regular": return UIFont.Weight.regular
            case .String(let value) where value == "bold": return UIFont.Weight.bold
            case .Null: return nil
            case let value: throw "Unexpected value for font-weight: \(value)"
            }
        }
        
        if size != nil || weight != nil || italic {
            let descriptor = UIFontDescriptor(fontAttributes: [
                .family: family,
                .traits: [
                    UIFontDescriptor.TraitKey.weight: weight ?? UIFont.Weight.regular,
                    UIFontDescriptor.TraitKey.slant: italic ? 1 : 0,
                ]
                ])
            
            string.addAttribute(
                .font,
                value: UIFont(descriptor: descriptor, size: size ?? 12),
                range: NSRange(location: 0, length: string.length))
        }
        
        let lineHeightMultiple: Float = try props.get("line-height") {
            switch $0 {
            case .Object(let value):
                // Assume unit is percent because that is the only thing we support as of now.
                return try value.get("value") {
                    switch $0 {
                    case .Number(let value): return value / 100.0
                    case let value: throw "Unexpected value for value: \(value)"
                    }
                }
            case .Null: return 1.0
            case let value: throw "Unexpected value for line-height: \(value)"
            }
        }
        
        try props.get("font-color") {
            switch $0 {
            case .Object(let value):
                try value.get("default") {
                    switch $0 {
                    case .String(let value):
                        string.addAttribute(
                            .foregroundColor,
                            value: try UIColor(hex: value),
                            range: NSRange(location: 0, length: string.length))
                    case let value: throw "Unexpected value for color: \(value)"
                    }
                }
            case .Null: ()
            case let value: throw "Unexpected value for font-color: \(value)"
            }
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = CGFloat(lineHeightMultiple)

        string.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: string.length))
        
        return string
    }
    
    override func setProps(_ props: [String: JSON]) throws {
        self.baseProps = try VMLBaseProps(props)
        self.text = try attributedString(from: props)
        
        self.numberOfLines = try props.get("max-lines") {
            switch $0 {
            case .Number(let value): return Int(value)
            case .Null: return -1
            case let value: throw "Unexpected value for max-lines: \(value)"
            }
        }
        
        self.textAlignment = try props.get("text-align") {
            switch $0 {
            case .String(let value) where value == "start": return .left
            case .String(let value) where value == "center": return .center
            case .String(let value) where value == "end": return .right
            case .Null: return .left
            case let value: throw "Unexpected value for text-align: \(value)"
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize  {
        return text.boundingRect(with: size, options: [.usesLineFragmentOrigin], context: nil).size
    }
    
    override func getView() -> VMLView  {
        self.view.frame = self.frame
        self.view.attributedText = text
        self.view.textAlignment = self.textAlignment
        self.view.numberOfLines = self.numberOfLines
        
        let wrapper = VMLViewWrapper(wrapping: self.view)
        wrapper.frame = frame
        baseProps?.apply(ctx: ctx, view: wrapper)
        return wrapper
    }
}
