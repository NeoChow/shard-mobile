/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

struct ShardError: Error {
    enum ErrorType {
        case HttpStatusCodeError
    }
    
    let type: ErrorType
    let message: String
}

public enum Result<T> {
    case Success(T)
    case Failure(Error)
}

private func shard_view_manager_create_view(_ self_ptr: UnsafeRawPointer?, _ context_ptr: UnsafeRawPointer?, _ kind: UnsafePointer<Int8>?) -> UnsafeMutablePointer<IOSView>? {
    let viewManager: ShardViewManager = Unmanaged.fromOpaque(UnsafeRawPointer(self_ptr!)).takeUnretainedValue()
    let context: ShardContext = Unmanaged.fromOpaque(UnsafeRawPointer(context_ptr!)).takeUnretainedValue()
    let view = viewManager.createView(context: context, kind: String(cString: kind!))
    return view.rust_ptr;
}

public typealias ViewImplFactory = (ShardContext) -> ShardViewImpl

public class ShardViewManager {
    public static let shared = ShardViewManager()
    
    internal var rust_ptr: OpaquePointer! = nil
    private let defaultSession = URLSession(configuration: .default)
    internal var implFactories: Dictionary<String, ViewImplFactory> = [:]
    
    private init() {
        let self_ptr = Unmanaged.passUnretained(self).toOpaque()
        self.rust_ptr = shard_view_manager_new(self_ptr, shard_view_manager_create_view)
        
        setViewImpl("flexbox", { FlexboxViewImpl($0) })
        setViewImpl("image", { ImageViewImpl($0) })
        setViewImpl("text", { TextViewImpl($0) })
        setViewImpl("scroll", { ScrollViewImpl($0) })
        setViewImpl("solid-color", { SolidColorViewImpl($0) })
    }
    
    deinit {
        shard_view_manager_free(rust_ptr)
    }
    
    public func setViewImpl(_ kind: String, _ factory: @escaping ViewImplFactory) {
        self.implFactories[kind] = factory
    }
    
    func createView(context: ShardContext, kind: String) -> ShardView {
        return ShardView(implFactories[kind]!(context))
    }
    
    public func loadUrl(url: URL, onComplete: @escaping (Result<ShardRoot>) -> Void) {
        let task = self.defaultSession.dataTask(with: url) { data, response, httpError in
            guard httpError == nil else {
                onComplete(Result.Failure(httpError!))
                
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                
                if (statusCode != 200) {
                    onComplete(Result.Failure(
                        ShardError(
                            type: .HttpStatusCodeError,
                            message: "Server responded with status code \(statusCode)."
                        )
                    ))
                    
                    return
                }
                
                do {
                    let json = JsonValue(try JSONSerialization.jsonObject(with: data!, options: []))
                    DispatchQueue.main.async {
                        onComplete(Result.Success(self.loadJson(json)))
                    }
                } catch let error {
                    onComplete(Result.Failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    public func loadJson(_ json: JsonValue) -> ShardRoot {
        return loadJson(json.toString())
    }
    
    public func loadJson(_ json: String) -> ShardRoot {
        let context = ShardContext()
        let context_ptr = Unmanaged.passUnretained(context).toOpaque()
        return ShardRoot(context, shard_render(self.rust_ptr, context_ptr, (json as NSString).utf8String))
    }
}
