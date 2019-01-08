/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public class VMLRootView: UIView {
    private let root: VMLRoot
    private var lastSize: CGSize? = nil
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public init(_ root: VMLRoot) {
        self.root = root
        super.init(frame: .zero)
        addSubview(self.root.view)
    }
    
    public override func layoutSubviews() {
        if lastSize == nil || lastSize != self.frame.size {
            self.root.sizeToFit(width: self.frame.width, height: self.frame.height)
            lastSize = self.frame.size
        }
    }
}
