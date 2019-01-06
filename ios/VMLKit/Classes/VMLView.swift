/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

private func vml_view_set_frame(_ context: UnsafeRawPointer?, _ start: Float, _ end: Float, _ top: Float, _ bottom: Float) {
    let view: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    view.frame = CGRect(x: CGFloat(start), y: CGFloat(top), width: CGFloat(end - start), height: CGFloat(bottom - top))
}

private func vml_view_set_prop(_ context: UnsafeRawPointer?, _ key: UnsafePointer<Int8>?, _ value: UnsafePointer<Int8>?) {
    let view: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    let key = String(cString: key!)
    let value = String(cString: value!)
    view.setProp(key, value)
}

private func vml_view_add_child(_ context: UnsafeRawPointer?, _ child: UnsafeRawPointer?) {
    let view: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    let child: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(child!)).takeUnretainedValue()
    view.children.append(child)
}

private func vml_view_measure(_ context: UnsafeRawPointer?, _ size: CSize) -> CSize {
    let view: VMLView = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    return view.measure(size)
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
    
    public var view: UIView {
        let view = impl.createView()
        view.frame = self.frame
        impl.bindView(view)
        
        if impl is FlexboxViewImpl {
            for child in self.children {
                view.addSubview(child.view)
            }
        } else if children.count > 0 {
            assertionFailure("Only flexbox is allowed to specify children")
        }
        
        return view
    }
    
    func setProp(_ key: String, _ value: String) {
        impl.setProp(key: key, value: JsonValue(try! JSONSerialization.jsonObject(with: value.data(using: .utf8)!, options: [.allowFragments])))
    }
    
    func measure(_ size: CSize) -> CSize {
        let size = impl.measure(
            width: size.width.isNaN ? nil : CGFloat(size.width),
            height: size.height.isNaN ? nil : CGFloat(size.height))
        return CSize(width: Float(size.width), height: Float(size.height))
    }
}
