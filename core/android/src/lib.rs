use core;

extern crate jni;
use self::jni::JNIEnv;
use self::jni::objects::{JString, JObject, JValue};

use std::ffi::{CStr};

#[no_mangle]
#[allow(non_snake_case)]
pub unsafe extern fn Java_app_visly_VML_getKind(env: JNIEnv, _: JObject, json: JString, callback_obj: JObject) {
    let jni_str = env.get_string(json).expect("invalid json string");
    let json_str = CStr::from_ptr(jni_str.as_ptr()).to_str().unwrap();

    core::vml_json_get_kind(json_str, |kind| {
      let kind = env.new_string(kind.unwrap()).expect("Couldn't create java string!");
      env.call_method(callback_obj, "result", "(Ljava/lang/String;)V", &[JValue::from(JObject::from(kind))]).unwrap();
    });
}