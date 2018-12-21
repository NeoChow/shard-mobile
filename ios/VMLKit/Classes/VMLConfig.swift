/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
import Foundation

internal struct HashableClass: Hashable {
    let `class`: AnyClass
    
    static func ==(lhs: HashableClass, rhs: HashableClass) -> Bool {
        return lhs.class == rhs.class
    }
    
    var hashValue: Int {
        return ObjectIdentifier(self.class).hashValue
    }
}

public typealias ShadowViewConstructor = (VMLContext, VMLShadowViewParent?) -> VMLShadowView

public class VMLConfig: NSObject {
    public static var `default`: VMLConfig = VMLConfig.Builder().build()
    
    internal let shadowViews: [String: ShadowViewConstructor]
 
    public func makeDefault() {
        VMLConfig.default = self
    }
    
    internal init(shadowViews: [String: ShadowViewConstructor]) {
        self.shadowViews = shadowViews
    }
    
    public class Builder {
        var shadowViews: [String: ShadowViewConstructor] = [:]
        
        public init() {
            addView(kind: "flexbox", shadowView: { VMLYogaShadowView($0, $1) })
            addView(kind: "text", shadowView: { VMLTextShadowView($0, $1) })
            addView(kind: "image", shadowView: { VMLImageShadowView($0, $1) })
            addView(kind: "scroll", shadowView: { VMLScrollShadowView($0, $1) })
            addView(kind: "solid-color", shadowView: { VMLSolidColorShadowView($0, $1) })
        }
        
        @discardableResult public func addView(kind: String, shadowView: @escaping ShadowViewConstructor) -> Builder {
            shadowViews[kind] = shadowView
            return self
        }

        public func build() -> VMLConfig {
            return VMLConfig(shadowViews: shadowViews)
        }
    }
}
