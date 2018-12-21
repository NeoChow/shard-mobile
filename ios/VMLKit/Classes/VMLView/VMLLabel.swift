/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

internal class VMLLabel: UILabel, Stateful {
    private var textColors: [UIControlState : UIColor] = [:]
    private var state: UIControlState = .normal
    
    func setTextColor(_ color: UIColor, forState state: UIControlState) {
        textColors[state] = color
        if state == self.state {
            textColor = color
        }
    }
    
    func set(state: UIControlState) {
        self.state = state
        textColor = textColors[state] ?? textColors[.normal]
    }
}
