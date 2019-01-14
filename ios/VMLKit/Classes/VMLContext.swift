//
//  VMLContext.swift
//  VMLKit
//
//  Created by Emil Sjölander on 1/11/19.
//

import Foundation

internal protocol VMLContextDelegate {
    func onActionDispatched(action: String, value: JsonValue?)
}

public class VMLContext {
    internal var delegate: VMLContextDelegate? = nil
    
    public func dispatch(action: String, value: JsonValue?) {
        delegate?.onActionDispatched(action: action, value: value)
    }
}
