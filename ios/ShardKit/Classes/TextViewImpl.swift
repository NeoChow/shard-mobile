/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

private let systemFont = UIFont.systemFont(ofSize: 12)

internal class TextViewImpl: BaseViewImpl {
    internal var text: NSAttributedString = NSAttributedString()
    internal var numberOfLines: Int = -1
    internal var textAlignment: NSTextAlignment = .left
    internal var lineHeightMultiple = Float(1)
    
    override func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        let constraint = CGSize(width: width ?? CGFloat.greatestFiniteMagnitude, height: height ?? CGFloat.greatestFiniteMagnitude)
        let size = textWithLineHeight().boundingRect(with: constraint, options: [.usesLineFragmentOrigin], context: nil).size
        return CGSize(width: width ?? ceil(size.width), height: height ?? ceil(size.height))
    }
    
    override func setProp(key: String, value: JsonValue) throws {
        try super.setProp(key: key, value: value)
        
        switch key {
        case "span": self.text = try attributedString(from: try value.asObject(), attributes: [:])
        case "max-lines": self.numberOfLines = Int(try value.asNumber())
        case "line-height": self.lineHeightMultiple = try value.asObject()["value"]!.asNumber()
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
        label.font = systemFont
        label.isUserInteractionEnabled = true
        return label
    }
    
    override func bindView(_ view: UIView) {
        super.bindView(view)
        
        let view = view as! UILabel
        view.attributedText = textWithLineHeight()
        
        view.textAlignment = self.textAlignment
        view.numberOfLines = self.numberOfLines
    }
    
    func attributedString(from props: [String: JsonValue], attributes: [NSAttributedString.Key : Any], location: Int? = nil) throws -> NSAttributedString {
        var attributes = attributes
        let currentFont = attributes[.font] as! UIFont?
        
        let family: String = try props.get("font-family") {
            switch $0 {
            case .String(let value):
                if !UIFont.familyNames.contains(value) {
                    throw "Unexpected value for font-family: \(value)"
                }
                return value
            case .Null: return currentFont?.familyName ?? systemFont.familyName
            case let value: throw "Unexpected value for font-family: \(value)"
            }
        }
        
        let size: CGFloat = try props.get("font-size") {
            switch $0 {
            case .Object(let value): return CGFloat(try value.asDimension())
            case .Null: return currentFont?.pointSize ?? systemFont.pointSize
            case let value: throw "Unexpected value for font-size: \(value)"
            }
        }
        
        let italic: Bool? = try props.get("font-style") {
            switch $0 {
            case .String(let value) where value == "normal": return false
            case .String(let value) where value == "italic": return true
            case .Null: return nil
            case let value: throw "Unexpected value for font-style: \(value)"
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
        
        if weight != nil || italic != nil {
            var traits: UIFontDescriptor.SymbolicTraits = currentFont?.fontDescriptor.symbolicTraits ?? []
            
            if let weight = weight {
                if weight == UIFont.Weight.bold {
                    traits.insert(.traitBold)
                } else {
                    traits.remove(.traitBold)
                }
            }
            
            if let italic = italic {
                if italic {
                    traits.insert(.traitItalic)
                } else {
                    traits.remove(.traitItalic)
                }
            }
            
            let descriptor = UIFontDescriptor(fontAttributes: [.family: family]).withSymbolicTraits(traits)!
            attributes[.font] = UIFont(descriptor: descriptor, size: size)
        } else if attributes[.font] == nil {
            attributes[.font] = UIFont(name: family, size: size)
        }
        
        try props.get("font-color") {
            switch $0 {
            case .Null: ()
            case let value:
                attributes[.foregroundColor] =  try value.asColor().default
            }
        }
        
        let string: NSMutableAttributedString = try props.get("text") {
            switch $0 {
            case .String(let value):
                let string = NSMutableAttributedString(string: value)
                string.addAttributes(attributes, range: NSRange(location: 0, length: string.length))
                
                return string
            case .Array(let values):
                var location = location ?? 0
                let parts = try values.map({ (value) -> NSAttributedString in
                    let part = try attributedString(from: value.asObject(), attributes: attributes, location: location)
                    location += part.length
                    return part
                })
                return NSMutableAttributedString(
                    attributedString: parts.reduce(NSAttributedString(), { $0 + $1 })
                )
            case let value: throw "Unexpected value for text: \(value)"
            }
        }
        
        try props.get("link") {
            switch $0 {
            case .Null: ()
            case let value:
                let value = try value.asObject()
                let action = try value["action"]!.asString()
                let range = NSRange(location: location ?? 0, length: string.length)
                
                self.tapHandler = { sender -> () in
                    let label = sender.view as! UILabel
                    let charIndex = sender.tappedCharInAttributedText(inLabel: label)
                    
                    if charIndex != nil && NSLocationInRange(charIndex!, range) {
                        switch sender.state {
                        case .began:
                            self.delegate?.setState(.Pressed)
                        case .ended:
                            self.delegate?.setState(.Default)
                            //self.context.dispatch(action: action, value: value["value"])
                            print("Trigger event: \(action):\(try! value["value"]!.asString())")
                        default: ()
                        }
                    }
                }
            }
        }
        
        return string
    }
    
    private func textWithLineHeight() -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = CGFloat(lineHeightMultiple)
        paragraphStyle.alignment = textAlignment
        
        string.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: string.length))
        
        return string
    }
}

internal extension UITapGestureRecognizer {
    func tappedCharInAttributedText(inLabel label: UILabel) -> Int? {
        guard let attributedString = label.attributedText else {
            return nil
        }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: attributedString)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.size = label.bounds.size
        
        let locationOfTouchInLabel = self.location(in: label)
        
        let charIndex = layoutManager.glyphIndex(
            for: locationOfTouchInLabel,
            in: textContainer
        )
        
        let charRect = layoutManager.boundingRect(
            forGlyphRange: NSRange(location: charIndex, length: 1),
            in: textContainer
        )
        
        if !charRect.contains(locationOfTouchInLabel) {
            return nil
        }
        
        return charIndex
    }
}
