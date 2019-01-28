/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public class ShardRoot {
    internal let context: ShardContext
    private let root: IOSRoot
    
    internal init(_ context: ShardContext, _ root: IOSRoot) {
        self.context = context
        self.root = root
    }
    
    deinit {
        shard_root_free(self.root)
    }
    
    public func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        shard_root_measure(root, CSize(width: Float(width ?? CGFloat.nan), height: Float(height ?? CGFloat.nan)), nil)
        let rootView: ShardView = Unmanaged.fromOpaque(UnsafeRawPointer(shard_root_get_view(root)!)).takeUnretainedValue()
        return rootView.size
    }
    
    func layout(width: CGFloat?, height: CGFloat?) -> CGSize {
        shard_root_measure(root, CSize(width: Float(width ?? CGFloat.nan), height: Float(height ?? CGFloat.nan)), nil)
        let rootView: ShardView = Unmanaged.fromOpaque(UnsafeRawPointer(shard_root_get_view(root)!)).takeUnretainedValue()
        
        func updateFrame(_ root: ShardView) {
            root.view.frame = root.frame
            root.impl.bindView(root.view)
            for child in root.children {
                updateFrame(child)
            }
        }

        updateFrame(rootView)
        return rootView.size
    }
    
    internal lazy var view: UIView = {
        let rootView: ShardView = Unmanaged.fromOpaque(UnsafeRawPointer(shard_root_get_view(root)!)).takeUnretainedValue()
        
        func createViewHierarchy(_ root: ShardView) -> UIView {
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
