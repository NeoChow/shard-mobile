/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
import UIKit

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

public extension UIColor {
    convenience init(hex: String) throws {
        var normalized = hex
        
        if normalized.hasPrefix("#") {
            normalized.remove(at: normalized.startIndex)
        }
        
        switch normalized.count {
        case 3: normalized = "FF" + String([normalized[0], normalized[0], normalized[1], normalized[1], normalized[2], normalized[2]])
        case 6: normalized = "FF" + normalized
        case 8: ()
        default: throw "Unexpected value for color: \(hex)"
        }
        
        var argb: UInt32 = 0
        Scanner(string: normalized).scanHexInt32(&argb)
        
        self.init(
            red: CGFloat((argb & 0x00FF0000) >> 16) / 255.0,
            green: CGFloat((argb & 0x0000FF00) >> 8) / 255.0,
            blue: CGFloat(argb & 0x000000FF >> 0) / 255.0,
            alpha: CGFloat((argb & 0xFF000000) >> 24) / 255.0
        )
    }
}

internal extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

extension UIControl.State: Hashable {
    public var hashValue: Int {
        return Int(rawValue)
    }
}

extension NSAttributedString {
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}

