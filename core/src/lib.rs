
pub fn vml_json_get_kind<F>(json_str: &str, callback: F) where F: Fn(Option<&str>) -> () {
    let view = json::parse(json_str).unwrap();
    match view["kind"] {
        json::JsonValue::Short(ref value) => {
            callback(Some(value.as_str()));
        },
        _ => callback(None),
    };
}