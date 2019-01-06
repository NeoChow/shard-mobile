mod test;
use std::any::Any;
use stretch::geometry::Rect;

#[test]
fn render_view_of_kind() {
    let context: Option<&Any> = None;

    let root = core::render_root(
        &test::ViewManager {},
        &context,
        r#"{
        "root": {
            "kind": "test", 
            "layout": {}
        }
    }"#,
    );

    let view = root
        .view_node
        .vml_view
        .as_any()
        .downcast_ref::<test::View>()
        .unwrap();
    assert_eq!(view.kind, "test");
}

#[test]
fn render_view_with_flex_direction() {
    let context: Option<&Any> = None;

    let root = core::render_root(
        &test::ViewManager {},
        &context,
        r#"{
        "root": {
            "kind": "test", 
            "layout": {
                "flex-direction": "column"
            }
        }
    }"#,
    );

    assert_eq!(
        root.stretch_node.flex_direction,
        stretch::style::FlexDirection::Column
    );
}

#[test]
fn render_view_with_size() {
    let context: Option<&Any> = None;
    
    let root = core::render_root(
        &test::ViewManager {},
        &context,
        r#"{
        "root": {
            "kind": "test", 
            "layout": {
                "width": {"unit": "points", "value": 100},
                "height": {"unit": "points", "value": 100}
            }
        }
    }"#,
    );

    let view = root
        .view_node
        .vml_view
        .as_any()
        .downcast_ref::<test::View>()
        .unwrap();
    assert_eq!(
        view.frame,
        Rect {
            start: 0.0,
            end: 100.0,
            top: 0.0,
            bottom: 100.0,
        }
    );
}

#[test]
fn render_view_with_children() {
    let context: Option<&Any> = None;
    
    let root = core::render_root(
        &test::ViewManager {},
        &context,
        r#"{
        "root": {
            "kind": "test", 
            "layout": {},
            "children": [
                {"kind": "test", "layout": {}},
                {"kind": "test", "layout": {}}
            ]
        }
    }"#,
    );

    assert_eq!(root.view_node.children.len(), 2);
    assert_eq!(root.stretch_node.children.len(), 2);

    let view = root
        .view_node
        .vml_view
        .as_any()
        .downcast_ref::<test::View>()
        .unwrap();
    assert_eq!(view.child_count, 2);
}

#[test]
fn render_view_with_props() {
    let context: Option<&Any> = None;
    
    let root = core::render_root(
        &test::ViewManager {},
        &context,
        r#"{
        "root": {
            "kind": "test", 
            "layout": {},
            "props": {
                "one": "hello",
                "two": "world"
            }
        }
    }"#,
    );

    let view = root
        .view_node
        .vml_view
        .as_any()
        .downcast_ref::<test::View>()
        .unwrap();
    assert_eq!(view.props["one"], "\"hello\"");
    assert_eq!(view.props["two"], "\"world\"");
}

#[test]
fn render_view_intrinsic_size() {
    let context: Option<&Any> = None;
    
    let root = core::render_root(
        &test::ViewManager {},
        &context,
        r#"{
        "root": {
            "kind": "test", 
            "layout": {}
        }
    }"#,
    );

    let view = root
        .view_node
        .vml_view
        .as_any()
        .downcast_ref::<test::View>()
        .unwrap();
    assert_eq!(
        view.frame,
        Rect {
            start: 0.0,
            end: 100.0,
            top: 0.0,
            bottom: 100.0,
        }
    );
}
