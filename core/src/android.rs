#![allow(non_snake_case)]

extern crate jni;

use super::*;
use self::jni::JNIEnv;
use self::jni::objects::{JString, JObject, JValue};

use std::os::raw::{c_char, c_void};
use std::ffi::{CStr};

#[no_mangle]
pub unsafe extern fn Java_app_visly_VML_getKind(env: JNIEnv, _: JObject, json: JString, callback_obj: JObject) {
    let json = env.get_string(json).expect("invalid json string").as_ptr();

    fn callback(context: *const c_void, kind: *const c_char) {
      let context = unsafe { & *(context as *const (JNIEnv, JObject)) };
      let kind_ptr = unsafe { CStr::from_ptr(kind) };
      let kind = context.0.new_string(kind_ptr.to_str().unwrap()).expect("Couldn't create java string!");
      context.0.call_method(context.1, "result", "(Ljava/lang/String;)V", &[JValue::from(JObject::from(kind))]).unwrap();
    }

    let context = &(env, callback_obj) as *const _ as *const c_void;
    vml_json_get_kind(json, context, callback);
}