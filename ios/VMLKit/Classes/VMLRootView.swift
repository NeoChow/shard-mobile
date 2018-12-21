/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
import UIKit

public typealias EventHandler = ([String: JSON]) -> Void

public class VMLRootView: UIView {
    private var eventHandlers: [String: EventHandler] = [:]
    private let defaultSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?
    
    public func load(
        _ url: URL,
        config: VMLConfig = VMLConfig.default,
        onComplete: @escaping (Error?) -> Void = {(e: Error?) in
        if let e = e {
            print(e)
        }
        }) {
        
        dataTask?.cancel()
        
        dataTask = self.defaultSession.dataTask(with: url) { data, response, httpError in
            var vmlError: Error? = httpError
            let context = VMLContext(config: config, root: self)
            
            defer {
                self.dataTask = nil
                DispatchQueue.main.async {
                    onComplete(vmlError)
                }
            }
            
            do {
                let json = try JSON(try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]).asObject()
                
                try json.get("version") {
                    switch $0 {
                    case .String: ()
                    case let value: throw "Unexpected value for version: \(value)"
                    }
                }
                
                let root: [String: JSON]? = try json.get("root") {
                    switch $0 {
                    case .Object(let value): return value
                    case .Null: return nil
                    case let value: throw "Unexpected value for root: \(value)"
                    }
                }
                
                vmlError = try json.get("error") {
                    switch $0 {
                    case .String(let value): return value
                    case .Null: return nil
                    case let value: throw "Unexpected value for error: \(value)"
                    }
                }
                
                if let root = root {
                    DispatchQueue.main.async {
                        do {
                            let shadowView = try context.createShadowView(kind: "flexbox", parent: nil) as! VMLShadowViewParent
                            try shadowView.setProps(["flex-direction": JSON.String("column"), "children": JSON.Array([JSON.Object(root)])])
                            shadowView.setFrame(self.bounds)
                            shadowView.layoutChildren()
                            
                            for subview in self.subviews {
                                subview.removeFromSuperview()
                            }
                            self.addSubview(shadowView.getView())
                        } catch {
                            vmlError = error
                        }
                    }
                }
                
            } catch {
                vmlError = error
            }
        }
        
        dataTask?.resume()
    }
    
    public override func layoutSubviews() {
        for subview in subviews {
            subview.frame = self.bounds
        }
    }
    
    public func on(_ type: String, _ callback: EventHandler?) {
        if let callback = callback {
            self.eventHandlers[type] = callback
        } else {
            self.eventHandlers.removeValue(forKey: type)
        }
    }
    
    internal func dispatchEvent(type: String, data: [String: JSON]) {
        if let eventHandler = eventHandlers[type] {
            eventHandler(data)
        }
    }
}
