
// interface Property<View> {
//   void set(View v, JSON prop);
//   JSON get(View v);
// }

// interface Container extends View {
//   void addChild(View child, Rect frame, int index);
//   void removeChild(View child);
// }

// interface View {
//   Self instance;
//   Map<String, Property<Self>> getProps();
// }

// interface Platform {
//   View makeView(String kind);
//   Container makeContainer();
// }

// interface CrustView {
//   constructor(JSON desc);
// }

#[cfg(target_os="android")]
pub mod android;

use std::os::raw::{c_char, c_void};
use std::ptr;
use std::ffi::{CString, CStr};

use json;

#[no_mangle]
pub extern fn vml_json_get_kind(json_str: *const c_char, context: *const c_void, callback: fn(*const c_void, *const c_char) -> ()) {
    let json_str = unsafe { CStr::from_ptr(json_str).to_str().unwrap() };
    let view = json::parse(json_str).unwrap();
    match view["kind"] {
        json::JsonValue::Short(ref value) => {
            let kind = CString::new(value.as_str()).expect("CString::new failed");
            callback(context, kind.as_ptr());
        },
        _ => callback(context, ptr::null()),
    };
}
