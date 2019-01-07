/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

private let systemFont = UIFont.systemFont(ofSize: 10);

internal class TextViewImpl: BaseViewImpl {
    internal var text: NSAttributedString = NSAttributedString()
    internal var numberOfLines: Int = -1
    internal var textAlignment: NSTextAlignment = .left
    internal var lineHeightMultiple = Float(1)
    
    override func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        let size = CGSize(width: width ?? CGFloat.greatestFiniteMagnitude, height: height ?? CGFloat.greatestFiniteMagnitude)
        return textWithLineHeight().boundingRect(with: size, options: [.usesLineFragmentOrigin], context: nil).size
    }
    
    override func setProp(key: String, value: JsonValue) {
        super.setProp(key: key, value: value)
        
        switch key {
        case "span": self.text = try! attributedString(from: try! value.asObject())
        case "max-lines": self.numberOfLines = Int(try! value.asNumber())
        case "line-height": self.lineHeightMultiple = try! value.asObject()["value"]!.asNumber()
        case "text-align":
            switch value {
            case .String(let value) where value == "start": self.textAlignment = .left
            case .String(let value) where value == "center": self.textAlignment = .center
            case .String(let value) where value == "end": self.textAlignment = .right
            default: self.textAlignment = .left
            }
        default: ()
        }
    }
    
    override func createView() -> UIView {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }
    
    override func bindView(_ view: UIView) {
        super.bindView(view)
        
        let view = view as! UILabel
        view.attributedText = textWithLineHeight()
        view.textAlignment = self.textAlignment
        view.numberOfLines = self.numberOfLines
    }
    
    func attributedString(from props: [String: JsonValue]) throws -> NSAttributedString {
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
        
        try props.get("font-color") {
            switch $0 {
            case .String(let value):
                string.addAttribute(
                    .foregroundColor,
                    value: try UIColor(hex: value),
                    range: NSRange(location: 0, length: string.length))
            case .Null: ()
            case let value: throw "Unexpected value for font-color: \(value)"
            }
        }
        
        return string
    }
    
    private func textWithLineHeight() -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = CGFloat(lineHeightMultiple)
        
        string.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: string.length))
        return string
    }
}
