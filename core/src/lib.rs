
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

use std::os::raw::{c_char};
use std::ffi::{CString, CStr};

#[no_mangle]
pub extern fn vml_hello(to: *const c_char) -> *mut c_char {
    let c_str = unsafe { CStr::from_ptr(to) };
    let recipient = match c_str.to_str() {
        Err(_) => "there",
        Ok(string) => string,
    };

    CString::new("Hello ".to_owned() + recipient).unwrap().into_raw()
}

#[no_mangle]
pub extern fn vml_hello_free(s: *mut c_char) {
    unsafe {
        if s.is_null() { return }
        CString::from_raw(s)
    };
}
