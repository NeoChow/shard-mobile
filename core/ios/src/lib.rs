/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
use json::JsonValue;
use std::any::Any;
use std::f32;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_void};
use stretch::geometry::Rect;
use stretch::geometry::Size;
use stretch::number::*;

pub struct IOSViewManager {
    context: *const c_void,
    create_view: fn(*const c_void, *const c_char) -> *mut IOSView,
}

impl core::VMLViewManager for IOSViewManager {
    fn create_view(&self, _: &Any, kind: &str) -> Box<core::VMLView> {
        let kind = CString::new(kind).unwrap();
        let create_view = self.create_view;
        let view = create_view(self.context, kind.as_ptr());
        unsafe { Box::from_raw(view) }
    }
}

#[repr(C)]
pub struct CSize {
    width: f32,
    height: f32,
}

#[repr(C)]
pub struct IOSView {
    context: *const c_void,
    set_frame: fn(*const c_void, f32, f32, f32, f32) -> (),
    set_prop: fn(*const c_void, *const c_char, *const c_char) -> (),
    add_child: fn(*const c_void, *const c_void) -> (),
    measure: fn(*const c_void, CSize) -> CSize,
}

impl core::VMLView for IOSView {
    fn add_child(&mut self, child: &core::VMLView) {
        let add_child = self.add_child;
        let child = child.as_any().downcast_ref::<IOSView>().unwrap();
        add_child(self.context, child.context);
    }

    fn measure(&self, constraints: Size<Number>) -> Size<f32> {
        let measure = self.measure;
        let width = constraints.width.or_else(f32::NAN);
        let height = constraints.height.or_else(f32::NAN);
        let size = measure(self.context, CSize { width, height });
        Size {
            width: size.width,
            height: size.height,
        }
    }

    fn set_prop(&mut self, key: &str, value: &JsonValue) {
        let key = CString::new(key).unwrap();
        let value = CString::new(value.dump()).unwrap();
        let set_prop = self.set_prop;
        set_prop(self.context, key.as_ptr(), value.as_ptr());
    }

    fn set_frame(&mut self, frame: Rect<f32>) {
        let set_frame = self.set_frame;
        set_frame(
            self.context,
            frame.start,
            frame.end,
            frame.top,
            frame.bottom,
        );
    }

    fn as_any(&self) -> &Any {
        self
    }
}

#[no_mangle]
pub extern "C" fn vml_view_new(
    context: *const c_void,
    set_frame: fn(*const c_void, f32, f32, f32, f32) -> (),
    set_prop: fn(*const c_void, *const c_char, *const c_char) -> (),
    add_child: fn(*const c_void, *const c_void) -> (),
    measure: fn(*const c_void, CSize) -> CSize,
) -> *mut IOSView {
    Box::into_raw(Box::new(IOSView {
        context,
        set_frame,
        set_prop,
        add_child,
        measure,
    }))
}

#[no_mangle]
pub extern "C" fn vml_view_free(view: *mut IOSView) {
    unsafe {
        Box::from_raw(view);
    }
}

#[no_mangle]
pub extern "C" fn vml_view_manager_new(
    context: *const c_void,
    create_view: fn(*const c_void, *const c_char) -> *mut IOSView,
) -> *const IOSViewManager {
    Box::into_raw(Box::new(IOSViewManager {
        context,
        create_view,
    }))
}

#[no_mangle]
pub extern "C" fn vml_view_manager_free(view_manager: *mut IOSViewManager) {
    unsafe {
        Box::from_raw(view_manager);
    }
}

#[no_mangle]
pub extern "C" fn vml_render(
    view_manager: *mut IOSViewManager,
    json: *const c_char,
) -> *const IOSView {
    let view_manager = unsafe { Box::from_raw(view_manager) };
    let json = unsafe { CStr::from_ptr(json).to_str().unwrap() };
    let context: Option<&Any> = None;
    let root = core::render_root(Box::leak(view_manager), &context, json);
    Box::into_raw(root.view_node.vml_view) as *const IOSView
}
