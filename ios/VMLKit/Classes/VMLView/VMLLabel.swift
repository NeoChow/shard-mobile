/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

internal class VMLLabel: UILabel, Stateful {
    private var textColors: [UIControl.State : UIColor] = [:]
    private var state: UIControl.State = .normal
    
    func setTextColor(_ color: UIColor, forState state: UIControl.State) {
        textColors[state] = color
        if state == self.state {
            textColor = color
        }
    }
    
    func set(state: UIControl.State) {
        self.state = state
        textColor = textColors[state] ?? textColors[.normal]
    }
}
