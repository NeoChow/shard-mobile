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
use std::ptr;
use stretch::geometry::Rect;
use stretch::geometry::Size;
use stretch::number::*;
use stretch::result::Result;

pub struct IOSViewManager {
    swift_ptr: *const c_void,
    create_view: fn(*const c_void, *const c_void, *const c_char, *mut *const c_char) -> *mut IOSView,
}

impl core::ShardViewManager for IOSViewManager {
    fn create_view(&self, context: &Any, kind: &str) -> Result<Box<core::ShardView>> {
        let context = context.downcast_ref::<*const c_void>().unwrap();
        let kind = CString::new(kind).unwrap();
        let create_view = self.create_view;
        let mut err: *const c_char = ptr::null();
        let view = create_view(self.swift_ptr, *context, kind.as_ptr(), &mut err as *mut *const c_char);

        if err.is_null() {
            Ok(unsafe { Box::from_raw(view) })
        } else {
            let err_string = unsafe { CStr::from_ptr(err).to_str().unwrap() };
            Err(Box::new(err_string))
        }
    }
}

#[repr(C)]
pub struct CSize {
    width: f32,
    height: f32,
}

#[repr(C)]
pub struct IOSView {
    swift_ptr: *const c_void,
    set_frame: fn(*const c_void, f32, f32, f32, f32, *mut *const c_char) -> (),
    set_prop: fn(*const c_void, *const c_char, *const c_char, *mut *const c_char) -> (),
    add_child: fn(*const c_void, *const c_void, *mut *const c_char) -> (),
    measure: fn(*const c_void, *const CSize, *mut *const c_char) -> CSize,
}

impl core::ShardView for IOSView {
    fn add_child(&mut self, child: &core::ShardView) -> Result<()> {
        let add_child = self.add_child;
        let child = child.as_any().downcast_ref::<IOSView>().unwrap();

        let mut err: *const c_char = ptr::null();
        add_child(self.swift_ptr, child.swift_ptr, &mut err as *mut *const c_char);

        if err.is_null() {
            Ok(())
        } else {
            let err_string = unsafe { CStr::from_ptr(err).to_str().unwrap() };
            Err(Box::new(err_string))
        }
    }

    fn measure(&self, constraints: Size<Number>) -> Result<Size<f32>> {
        let measure = self.measure;
        let width = constraints.width.or_else(f32::NAN);
        let height = constraints.height.or_else(f32::NAN);
        let csize = CSize { width, height };
        let mut err: *const c_char = ptr::null();
        let size = measure(self.swift_ptr, &csize as *const CSize, &mut err as *mut *const c_char);

        if err.is_null() {
            Ok(Size { width: size.width, height: size.height })
        } else {
            let err_string = unsafe { CStr::from_ptr(err).to_str().unwrap() };
            Err(Box::new(err_string))
        }
    }

    fn set_prop(&mut self, key: &str, value: &JsonValue) -> Result<()> {
        let key = CString::new(key).unwrap();
        let value = CString::new(value.dump()).unwrap();
        let set_prop = self.set_prop;
        let mut err: *const c_char = ptr::null();
        set_prop(self.swift_ptr, key.as_ptr(), value.as_ptr(), &mut err as *mut *const c_char);

        if err.is_null() {
            Ok(())
        } else {
            let err_string = unsafe { CStr::from_ptr(err).to_str().unwrap() };
            Err(Box::new(err_string))
        }
    }

    fn set_frame(&mut self, frame: Rect<f32>) -> Result<()> {
        let set_frame = self.set_frame;
        let mut err: *const c_char = ptr::null();
        set_frame(self.swift_ptr, frame.start, frame.end, frame.top, frame.bottom, &mut err as *mut *const c_char);

        if err.is_null() {
            Ok(())
        } else {
            let err_string = unsafe { CStr::from_ptr(err).to_str().unwrap() };
            Err(Box::new(err_string))
        }
    }

    fn as_any(&self) -> &Any {
        self
    }
}

#[repr(C)]
pub struct IOSRoot {
    root_ptr: *mut c_void,
}

#[no_mangle]
pub extern "C" fn shard_root_measure(root: IOSRoot, size: CSize, error: *mut *const c_char) {
    let mut root: Box<core::Root> = unsafe { Box::from_raw(root.root_ptr as *mut core::Root) };
    let result = root.measure(Size {
        width: if size.width.is_nan() { Number::Undefined } else { Number::Defined(size.width) },
        height: if size.height.is_nan() { Number::Undefined } else { Number::Defined(size.height) },
    });

    match result {
        Ok(_) => {
            Box::leak(root);
        }
        Err(err) => unsafe {
            let message = if let Some(error) = err.downcast_ref::<&str>() {
                *error
            } else if let Some(error) = err.downcast_ref::<String>() {
                error.as_str()
            } else {
                "Unknown native error"
            };

            *error = CString::new(message).unwrap().into_raw();
        },
    }
}

#[no_mangle]
pub extern "C" fn shard_root_get_view(root: IOSRoot) -> *const c_void {
    let root: Box<core::Root> = unsafe { Box::from_raw(root.root_ptr as *mut core::Root) };
    let view = root.view_node.shard_view.as_any().downcast_ref::<IOSView>().unwrap();
    let swift_ptr = view.swift_ptr;
    Box::leak(root);
    swift_ptr
}

#[no_mangle]
pub extern "C" fn shard_root_free(root: IOSRoot) {
    let _root: Box<core::Root> = unsafe { Box::from_raw(root.root_ptr as *mut core::Root) };
}

#[no_mangle]
pub extern "C" fn shard_view_new(
    swift_ptr: *const c_void,
    set_frame: fn(*const c_void, f32, f32, f32, f32, *mut *const c_char) -> (),
    set_prop: fn(*const c_void, *const c_char, *const c_char, *mut *const c_char) -> (),
    add_child: fn(*const c_void, *const c_void, *mut *const c_char) -> (),
    measure: fn(*const c_void, *const CSize, *mut *const c_char) -> CSize,
) -> *mut IOSView {
    Box::into_raw(Box::new(IOSView { swift_ptr, set_frame, set_prop, add_child, measure }))
}

#[no_mangle]
pub extern "C" fn shard_view_free(view: *mut IOSView) {
    unsafe {
        Box::from_raw(view);
    }
}

#[no_mangle]
pub extern "C" fn shard_view_manager_new(
    swift_ptr: *const c_void,
    create_view: fn(*const c_void, *const c_void, *const c_char, *mut *const c_char) -> *mut IOSView,
) -> *const IOSViewManager {
    Box::into_raw(Box::new(IOSViewManager { swift_ptr, create_view }))
}

#[no_mangle]
pub extern "C" fn shard_view_manager_free(view_manager: *mut IOSViewManager) {
    unsafe {
        Box::from_raw(view_manager);
    }
}

#[no_mangle]
pub extern "C" fn shard_render(
    view_manager: *mut IOSViewManager,
    context: *const c_void,
    json: *const c_char,
    error: *mut *const c_char,
) -> IOSRoot {
    let view_manager = unsafe { Box::from_raw(view_manager) };
    let json = unsafe { CStr::from_ptr(json).to_str().unwrap() };
    let result = core::render_root(Box::leak(view_manager), &context, json);

    match result {
        Ok(root) => IOSRoot { root_ptr: Box::into_raw(Box::new(root)) as *mut c_void },
        Err(err) => {
            let message = if let Some(error) = err.downcast_ref::<&str>() {
                *error
            } else if let Some(error) = err.downcast_ref::<String>() {
                error.as_str()
            } else {
                "Unknown native error"
            };

            unsafe {
                *error = CString::new(message).unwrap().into_raw();
            }
            IOSRoot { root_ptr: ptr::null_mut() }
        }
    }
}
