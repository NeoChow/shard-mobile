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
    internal var substringClickHandler: ((_ sender: UITapGestureRecognizer) -> ())? = nil
    
    internal lazy var substringTapGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleSubstringTap(sender:)))
        gesture.minimumPressDuration = 0
        return gesture
    }()
    
    override func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        let constraint = CGSize(width: width ?? CGFloat.greatestFiniteMagnitude, height: height ?? CGFloat.greatestFiniteMagnitude)
        let size = textWithLineHeight().boundingRect(with: constraint, options: [.usesLineFragmentOrigin], context: nil).size
        return CGSize(width: width ?? ceil(size.width), height: height ?? ceil(size.height))
    }
    
    override func setProp(key: String, value: JsonValue) {
        super.setProp(key: key, value: value)
        
        switch key {
        case "span": self.text = try! attributedString(from: try! value.asObject(), attributes: [:])
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
        label.isUserInteractionEnabled = true
        return label
    }
    
    override func bindView(_ view: UIView) {
        super.bindView(view)
        
        let view = view as! UILabel
        view.attributedText = textWithLineHeight()
        view.textAlignment = self.textAlignment
        view.numberOfLines = self.numberOfLines
        
        if (self.substringClickHandler != nil) {
            view.removeGestureRecognizer(self.substringTapGestureRecognizer)
            view.addGestureRecognizer(self.substringTapGestureRecognizer)
        }
    }
    
    func attributedString(from props: [String: JsonValue], attributes: [NSAttributedString.Key : Any], location: Int? = nil) throws -> NSAttributedString {
        var attributes = attributes
        
        let family: String = try props.get("font-family") {
            switch $0 {
            case .String(let value): return value
            case .Null: return systemFont.familyName
            case let value: throw "Unexpected value for font-family: \(value)"
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
        
        if size != nil || weight != nil || italic != nil {
            let current = attributes[.font] as! UIFont?
            var traits: UIFontDescriptor.SymbolicTraits = current?.fontDescriptor.symbolicTraits ?? []
            
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
            attributes[.font] = UIFont(descriptor: descriptor, size: size ?? current?.pointSize ?? 12)
        } else {
            attributes[.font] = systemFont // TODO: Set to parent?
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
                
                try props.get("link") {
                    switch $0 {
                    case .Null: ()
                    case let value:
                        let value = try value.asObject()
                        let action = try value["action"]!.asString()
                        let range = NSRange(location: location ?? 0, length: string.length)
                        
                        self.substringClickHandler = { sender -> () in
                            let label = sender.view as! UILabel
                            if sender.didTapAttributedTextInLabel(label: label, inRange: range) {
                                print("Trigger event: \(action):\(try! value["value"]!.asString())")
                            }
                        }
                    }
                }
                
                return string
            case .Array(let values):
                var location = 0
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
    
    @objc func handleSubstringTap(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .began: ()
        case .ended:
            self.substringClickHandler?(sender)
        default: ()
        }
    }
}

internal extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange characterRange: NSRange) -> Bool {
        guard let attributedString = label.attributedText else {
            return false
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
        
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(
            x: (textContainer.size.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (textContainer.size.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        
        let locationOfTouchInLabel = self.location(in: label)
        
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        
        let characterIndex = layoutManager.glyphIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer
        )
        
        let characterRect = layoutManager.boundingRect(
            forGlyphRange: NSRange(location: characterIndex, length: 1),
            in: textContainer
        )
        
        if !characterRect.contains(locationOfTouchInTextContainer) {
            return false
        }
        
        return NSLocationInRange(characterIndex, characterRange)
    }
}
