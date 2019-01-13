/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

private func vml_view_set_frame(_ self_ptr: UnsafeRawPointer?, _ start: Float, _ end: Float, _ top: Float, _ bottom: Float) {
    let view: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(self_ptr!)).takeUnretainedValue()
    view.frame = CGRect(x: CGFloat(start), y: CGFloat(top), width: CGFloat(end - start), height: CGFloat(bottom - top))
}

private func vml_view_set_prop(_ self_ptr: UnsafeRawPointer?, _ key: UnsafePointer<Int8>?, _ value: UnsafePointer<Int8>?) {
    let view: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(self_ptr!)).takeUnretainedValue()
    let key = String(cString: key!)
    let value = String(cString: value!)
    view.setProp(key, value)
}

private func vml_view_add_child(_ self_ptr: UnsafeRawPointer?, _ child_ptr: UnsafeRawPointer?) {
    let view: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(self_ptr!)).takeUnretainedValue()
    let child: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(child_ptr!)).takeUnretainedValue()
    view.children.append(child)
}

private func vml_view_measure(_ self_ptr: UnsafeRawPointer?, _ size: UnsafePointer<CSize>?) -> CSize {
    let view: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(self_ptr!)).takeUnretainedValue()
    return view.measure(size!.pointee)
}

public protocol VMLViewImpl {
    func measure(width: CGFloat?, height: CGFloat?) -> CGSize
    func setProp(key: String, value: JsonValue)
    func createView() -> UIView
    func bindView(_ view: UIView)
}

public class VMLView {
    internal var rust_ptr: UnsafeMutablePointer<IOSView>! = nil
    internal let impl: VMLViewImpl
    internal var frame: CGRect = .zero
    internal var children: Array<VMLView> = []
    
    init(_ impl: VMLViewImpl) {
        self.impl = impl
        let context = Unmanaged.passRetained(self).toOpaque()
        self.rust_ptr = vml_view_new(context, vml_view_set_frame, vml_view_set_prop, vml_view_add_child, vml_view_measure)
    }
    
    deinit {
        vml_view_free(rust_ptr)
    }
    
    public var size: CGSize {
         return frame.size
    }
    
    internal lazy var view: UIView = {
        return impl.createView()
    }()
    
    internal func setProp(_ key: String, _ value: String) {
        impl.setProp(key: key, value: JsonValue(try! JSONSerialization.jsonObject(with: value.data(using: .utf8)!, options: [.allowFragments])))
    }
    
    internal func measure(_ size: CSize) -> CSize {
        let size = impl.measure(
            width: size.width.isNaN ? nil : CGFloat(size.width),
            height: size.height.isNaN ? nil : CGFloat(size.height))
        return CSize(width: Float(size.width), height: Float(size.height))
    }
}
