//
//  VML.swift
//  Alamofire
//
//  Created by Emil Sjölander on 23/12/2018.
//

import UIKit

private func vml_view_manager_create_view(_ context: UnsafeRawPointer?, _ kind: UnsafePointer<Int8>?) -> UnsafeMutablePointer<IOSView>? {
    let viewManager: VMLViewManager = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    let view = viewManager.createView(kind: String(cString: kind!))
    return view.rust_ptr;
}

public class VMLViewManager {
    fileprivate var rust_ptr: OpaquePointer! = nil
    
    public init() {
        let context = Unmanaged.passUnretained(self).toOpaque()
        self.rust_ptr = vml_view_manager_new(context, vml_view_manager_create_view)
    }
    
    func createView(kind: String) -> View {
        return View(kind: kind)
    }
    
    public func render(json: String) -> View {
        let context = vml_render(self.rust_ptr, (json as NSString).utf8String)?.pointee.context
        return Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    }
}

private func vml_view_set_frame(_ context: UnsafeRawPointer?, _ start: Float, _ end: Float, _ top: Float, _ bottom: Float) {
    let view: View = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    view.frame = CGRect(x: CGFloat(start), y: CGFloat(top), width: CGFloat(end - start), height: CGFloat(bottom - top))
}

private func vml_view_set_prop(_ context: UnsafeRawPointer?, _ key: UnsafePointer<Int8>?, _ value: UnsafePointer<Int8>?) {
    let view: View = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    let key = String(cString: key!)
    let value = String(cString: value!)
    view.props[key] = value
}

private func vml_view_add_child(_ context: UnsafeRawPointer?, _ child: UnsafeRawPointer?) {
    let view: View = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    let child: View = Unmanaged.fromOpaque(UnsafeRawPointer(child!)).takeUnretainedValue()
    view.children.append(child)
}

private func vml_view_measure(_ context: UnsafeRawPointer?, _ size: CSize) -> CSize {
    let view: View = Unmanaged.fromOpaque(UnsafeRawPointer(context!)).takeUnretainedValue()
    return view.measure(size)
}

public class View {
    fileprivate var rust_ptr: UnsafeMutablePointer<IOSView>! = nil
    let kind: String
    var frame: CGRect = .zero
    var props: Dictionary<String, String> = [:]
    var children: Array<View> = []
    
    init(kind: String) {
        self.kind = kind
        let context = Unmanaged.passRetained(self).toOpaque()
        self.rust_ptr = vml_view_new(context, vml_view_set_frame, vml_view_set_prop, vml_view_add_child, vml_view_measure)
    }
    
    func measure(_ size: CSize) -> CSize {
        return CSize(width: 100.0, height: 100.0)
    }
}
