/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
import Foundation

public class VMLContext: NSObject {
    internal let config: VMLConfig
    internal let root: VMLRootView
    
    internal init(config: VMLConfig, root: VMLRootView) {
        self.config = config
        self.root = root
    }
    
    public func createShadowView(kind: String, parent: VMLShadowViewParent?) throws -> VMLShadowView {
        if let constructor = self.config.shadowViews[kind] {
            return constructor(self, parent)
        }
        
        throw "No shadow view for kind: \(kind)"
    }
    
    public func dispatchEvent(type: String, data: [String: JSON]) {
        root.dispatchEvent(type: type, data: data)
    }
}
