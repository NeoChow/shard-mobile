/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public class VMLRootView: UIView {
    private var root: VMLRoot? = nil
    private var lastSize: CGSize? = nil
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    public func setRoot(_ root: VMLRoot) {
        if self.root === root { return }
        self.root?.view.removeFromSuperview()
        lastSize = nil
        self.root = root
        addSubview(root.view)
    }
    
    public override func layoutSubviews() {
        if lastSize == nil || lastSize != self.frame.size {
            self.root?.layout(width: self.frame.width, height: self.frame.height)
            lastSize = self.frame.size
        }
    }
}
