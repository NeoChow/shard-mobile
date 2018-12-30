use core;

use std::os::raw::{c_char, c_void};
use std::ffi::{CStr};

#[no_mangle]
pub extern fn vml_json_get_kind(json_str: *const c_char, context: *const c_void, callback: fn(*const c_void, *const c_char) -> ()) {
    let json_str = unsafe { CStr::from_ptr(json_str).to_str().unwrap() };
    core::vml_json_get_kind(json_str, |kind| {
        callback(context, kind.unwrap().as_ptr() as *const c_char);
    });
}
