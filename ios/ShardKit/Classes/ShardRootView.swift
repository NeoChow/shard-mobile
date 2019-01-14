/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public class ShardRootView: UIView, ShardContextDelegate {
    private var root: ShardRoot? = nil
    private var lastSize: CGSize? = nil
    private var actionHandlers: Dictionary<String, (JsonValue?) -> ()> = [:]
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    public func setRoot(_ root: ShardRoot) {
        if self.root === root { return }
        self.root?.view.removeFromSuperview()
        self.root?.context.delegate = nil
        lastSize = nil
        self.root = root
        root.context.delegate = self
        addSubview(root.view)
    }
    
    public override func layoutSubviews() {
        if lastSize == nil || lastSize != self.frame.size {
            _ = self.root?.layout(width: self.frame.width, height: self.frame.height)
            lastSize = self.frame.size
        }
    }
    
    func onActionDispatched(action: String, value: JsonValue?) {
        actionHandlers[action]?(value)
    }
    
    public func on(_ action: String, _ callback: @escaping (JsonValue?) -> ()) {
        actionHandlers[action] = callback
    }
    
    public func off(_ action: String) {
        actionHandlers.removeValue(forKey: action)
    }
}
