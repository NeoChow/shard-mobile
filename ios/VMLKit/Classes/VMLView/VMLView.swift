/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
import UIKit

public enum BorderRadius {
    case Max
    case Points(Float)
}

public protocol VMLViewRequirements {
    func setTapHandler(_ onTap: @escaping () -> Void)
    func setBackgroundColor(_ color: UIColor, forState state: UIControl.State)
    func setBorderRadius(_ radius: BorderRadius)
    func setBorderColor(_ color: UIColor)
    func setBorderWidth(_ width: Float)
}

public protocol Stateful {
    func set(state: UIControl.State)
}

public typealias VMLView = UIView & VMLViewRequirements
