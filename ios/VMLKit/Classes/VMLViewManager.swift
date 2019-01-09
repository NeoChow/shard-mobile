/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

private func vml_view_manager_create_view(_ context: UnsafeRawPointer?, _ kind: UnsafePointer<Int8>?) -> UnsafeMutablePointer<IOSView>? {
    let viewManager: VMLViewManager = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    let view = viewManager.createView(kind: String(cString: kind!))
    return view.rust_ptr;
}

typealias ViewImplFactory = () -> VMLViewImpl

public class VMLViewManager {
    public static let shared = VMLViewManager()
    
    internal var rust_ptr: OpaquePointer! = nil
    private let defaultSession = URLSession(configuration: .default)
    internal var implFactories: Dictionary<String, ViewImplFactory> = [:]
    
    private init() {
        let context = Unmanaged.passUnretained(self).toOpaque()
        self.rust_ptr = vml_view_manager_new(context, vml_view_manager_create_view)
        
        setViewImpl("flexbox", { FlexboxViewImpl() })
        setViewImpl("image", { ImageViewImpl() })
        setViewImpl("text", { TextViewImpl() })
        setViewImpl("scroll", { ScrollViewImpl() })
        setViewImpl("solid-color", { SolidColorViewImpl() })
    }
    
    deinit {
        vml_view_manager_free(rust_ptr)
    }
    
    func setViewImpl(_ kind: String, _ factory: @escaping ViewImplFactory) {
        self.implFactories[kind] = factory
    }
    
    func createView(kind: String) -> VMLView {
        return VMLView(implFactories[kind]!())
    }
    
    public func loadUrl(url: URL, onComplete: @escaping (VMLRoot) -> ()) {
        let task = self.defaultSession.dataTask(with: url) { data, response, httpError in
            let json = JsonValue(try! JSONSerialization.jsonObject(with: data!, options: []))
            DispatchQueue.main.async { onComplete(self.loadJson(json)) }
        }
        task.resume()
    }
    
    public func loadJson(_ json: JsonValue) -> VMLRoot {
        return loadJson(json.toString())
    }
    
    public func loadJson(_ json: String) -> VMLRoot {
        return VMLRoot(vml_render(self.rust_ptr, (json as NSString).utf8String))
    }
}
