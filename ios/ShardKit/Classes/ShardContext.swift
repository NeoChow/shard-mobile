/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation

internal protocol ShardContextDelegate {
    func onActionDispatched(action: String, value: JsonValue?)
}

public class ShardContext {
    internal var delegate: ShardContextDelegate? = nil
    
    private(set) public var fontCollection: FontCollection
    
    public func dispatch(action: String, value: JsonValue?) {
        delegate?.onActionDispatched(action: action, value: value)
    }
    
    init(fontCollection: FontCollection = [:]) {
        self.fontCollection = fontCollection
    }
}
