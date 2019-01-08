/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public class VMLRoot {
    private let root: IOSRoot
    
    internal init(_ root: IOSRoot) {
        self.root = root
    }
    
    deinit {
        vml_root_free(self.root)
    }
    
    public func sizeThatFits(width: CGFloat?, height: CGFloat?) -> CGSize {
        vml_root_measure(root, CSize(width: Float(width ?? CGFloat.nan), height: Float(height ?? CGFloat.nan)))
        let rootView: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(vml_root_get_view(root)!)).takeUnretainedValue()
        return rootView.size
    }
    
    func sizeToFit(width: CGFloat?, height: CGFloat?) {
        vml_root_measure(root, CSize(width: Float(width ?? CGFloat.nan), height: Float(height ?? CGFloat.nan)))
        let rootView: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(vml_root_get_view(root)!)).takeUnretainedValue()
        updateFrame(rootView)
    }
    
    private func updateFrame(_ root: VMLView) {
        root.view.frame = root.frame
        root.impl.bindView(root.view)
        for child in root.children {
            updateFrame(child)
        }
    }
    
    internal lazy var view: UIView = {
        let rootView: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(vml_root_get_view(root)!)).takeUnretainedValue()
        
        func createViewHierarchy(_ root: VMLView) -> UIView {
            let view = root.view
            if root.impl is FlexboxViewImpl {
                for child in root.children {
                    view.addSubview(createViewHierarchy(child))
                }
            } else if root.children.count > 0 {
                assertionFailure("Only flexbox is allowed to specify children")
            }
            
            return view
        }
        
        return createViewHierarchy(rootView)
    }()
}
