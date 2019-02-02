/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public struct ShardError: Error {
    public enum ShardErrorType {
        case HttpStatusCodeError
        case UnknownResponseError
    }
    
    public let type: ShardErrorType
    public let message: String
}

public enum Result<T> {
    case Success(T)
    case Failure(Error)
}

private func shard_view_manager_create_view(
    _ self_ptr: UnsafeRawPointer?,
    _ context_ptr: UnsafeRawPointer?,
    _ kind: UnsafePointer<Int8>?,
    _ error: UnsafeMutablePointer<UnsafePointer<Int8>?>?) -> UnsafeMutablePointer<IOSView>? {
    
    let viewManager: ShardViewManager = Unmanaged.fromOpaque(UnsafeRawPointer(self_ptr!)).takeUnretainedValue()
    let context: ShardContext = Unmanaged.fromOpaque(UnsafeRawPointer(context_ptr!)).takeUnretainedValue()
    let view = viewManager.createView(context: context, kind: String(cString: kind!))
    return view.rust_ptr
}

public typealias ViewImplFactory = (ShardContext) -> ShardViewImpl
public typealias FontCollection = Dictionary<String, (_ size: CGFloat) -> UIFont>

public class ShardViewManager {
    public static let shared = ShardViewManager()
    public var session: NetworkSession = URLSession(configuration: .default)
    
    internal var rust_ptr: OpaquePointer! = nil
    internal var implFactories: Dictionary<String, ViewImplFactory> = [:]
    
    internal var fonts: FontCollection = [:]
    
    private init() {
        let self_ptr = Unmanaged.passUnretained(self).toOpaque()
        self.rust_ptr = shard_view_manager_new(self_ptr, shard_view_manager_create_view)
        
        setViewImpl("flexbox", { FlexboxViewImpl($0) })
        setViewImpl("image", { ImageViewImpl($0) })
        setViewImpl("text", { TextViewImpl($0, self.fonts) })
        setViewImpl("scroll", { ScrollViewImpl($0) })
        setViewImpl("solid-color", { SolidColorViewImpl($0) })
    }
    
    deinit {
        shard_view_manager_free(rust_ptr)
    }
    
    public func setViewImpl(_ kind: String, _ factory: @escaping ViewImplFactory) {
        self.implFactories[kind] = factory
    }
    
    public func registerFont(_ key: String, _ font: @escaping (_ size: CGFloat) -> UIFont) {
        self.fonts[key] = font
    }
    
    func createView(context: ShardContext, kind: String) -> ShardView {
        return ShardView(implFactories[kind]!(context))
    }
    
    func getResult(_ data: Data?, _ response: URLResponse?, _ httpError: Error?) -> Result<ShardRoot> {
        guard httpError == nil else {
            return Result.Failure(httpError!)
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if (httpResponse.statusCode != 200) {
                return Result.Failure(
                    ShardError(
                        type: .HttpStatusCodeError,
                        message: "Server responded with status code \(httpResponse.statusCode)."
                    )
                )
            }
        } else {
            return Result.Failure(
                ShardError(
                    type: .UnknownResponseError,
                    message: "Unknown response type."
                )
            )
        }
        
        let json = String(data: data!, encoding: .utf8)
        
        return loadJson(json!)
    }
    
    public func loadUrl(url: URL, onComplete: @escaping (Result<ShardRoot>) -> Void) {
        session.loadData(from: url) { data, response, httpError in
            let result = self.getResult(data, response, httpError)
            
            DispatchQueue.main.async {
                onComplete(result)
            }
        }
    }
    
    public func loadJson(_ json: JsonValue) -> Result<ShardRoot> {
        return loadJson(json.toString())
    }
    
    public func loadJson(_ json: String) -> Result<ShardRoot> {
        let context = ShardContext()
        let context_ptr = Unmanaged.passUnretained(context).toOpaque()
        
        var error: UnsafePointer<Int8>? = nil
        let error_ptr = UnsafeMutablePointer(&error)
        let ios_root = shard_render(self.rust_ptr, context_ptr, (json as NSString).utf8String, error_ptr)
        
        if let error = error {
            return Result.Failure(String(cString: error))
        } else {
            return Result.Success(ShardRoot(context, ios_root))
        }
    }
}
