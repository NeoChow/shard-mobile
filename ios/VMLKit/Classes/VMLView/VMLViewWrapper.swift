/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public class VMLViewWrapper<T: UIView>: VMLBaseView {
    let wrapping: T
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported initializer")
    }
    
    init(wrapping: T) {
        self.wrapping = wrapping
        super.init()
        addSubview(wrapping)
    }
    
    override public func layoutSubviews() {
        wrapping.frame = self.bounds
    }
    
    override public func set(state: UIControl.State) {
        super.set(state: state)
        
        if let wrapping = wrapping as? Stateful {
            wrapping.set(state: state)
        }
    }
}
