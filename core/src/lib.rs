use stretch::geometry::Size;
use stretch::geometry::Rect;
use stretch::style::Dimension;
use stretch::number::Number;

use json::JsonValue;
use std::any::Any;

pub trait VMLView: Any {
    fn add_child(&mut self, child: &VMLView);
    fn set_prop(&mut self, key: &str, value: &JsonValue);
    fn set_frame(&mut self, frame: Rect<f32>);
    fn measure(&self, constraints: Size<Number>) -> Size<f32>;
    fn as_any(&self) -> &Any;
}

pub trait VMLViewManager {
    fn create_view(&self, kind: &str) -> Box<VMLView>;
}

pub struct ViewNode{
    pub vml_view: Box<VMLView>,
    pub children: Vec<ViewNode>,
}

pub struct Root {
    pub view_node: ViewNode,
    pub stretch_node: stretch::style::Node,
}

pub fn render_root(platform: &VMLViewManager, json: &str) -> Root {
    let json = json::parse(json).unwrap();
    let mut root = render(platform, &json["root"]);
    set_frame(&mut root.view_node, &stretch::compute(&root.stretch_node));
    root
}

fn set_frame(view_node: &mut ViewNode, layout: &stretch::layout::Node) {
    view_node.vml_view.set_frame(Rect {
        start: layout.location.x,
        end: layout.location.x + layout.size.width,
        top: layout.location.y,
        bottom: layout.location.y + layout.size.height,
    });

    for i in 0..view_node.children.len() {
        let view_node = &mut view_node.children[i];
        let layout = &layout.children[i];
        set_frame(view_node, layout);
    }
}

fn render(platform: &VMLViewManager, view: &JsonValue) -> Root {
    let mut vml_view = platform.create_view(view["kind"].as_str().expect("Expected kind"));
    view["props"].entries().for_each(|(key, value)| vml_view.set_prop(key, value));

    let mut children: Vec<ViewNode> = vec![];
    let mut node_children: Vec<stretch::style::Node> = vec![];

    view["children"].members().for_each(|child| {
        let root = render(platform, child);
        children.push(root.view_node);
        node_children.push(root.stretch_node);
    });

    let raw_vml_view = &*vml_view as *const VMLView;

    children.iter().for_each(|child| vml_view.add_child(&*child.vml_view));

    let layout = match view["layout"] {
        JsonValue::Object(ref value) => value,
        _ => panic!("Expected layout"),
    };

    let stretch_node = stretch::style::Node {
        display: match layout["display"] {
            JsonValue::Short(ref value) if value == "flex" => stretch::style::Display::Flex,
            JsonValue::Short(ref value) if value == "none" => stretch::style::Display::None,
            _ => Default::default(),
        },

        position_type: match layout["position"] {
            JsonValue::Short(ref value) if value == "relative" => stretch::style::PositionType::Relative,
            JsonValue::Short(ref value) if value == "absolute" => stretch::style::PositionType::Absolute,
            _ => Default::default(),
        },

        direction: match layout["direction"] {
            JsonValue::Short(ref value) if value == "relative" => stretch::style::Direction::RTL,
            JsonValue::Short(ref value) if value == "absolute" => stretch::style::Direction::LTR,
            _ => Default::default(),
        },

        flex_direction: match layout["flex-direction"] {
            JsonValue::Short(ref value) if value == "row" => stretch::style::FlexDirection::Row,
            JsonValue::Short(ref value) if value == "row-reverse" => stretch::style::FlexDirection::RowReverse,
            JsonValue::Short(ref value) if value == "column" => stretch::style::FlexDirection::Column,
            JsonValue::Short(ref value) if value == "column-reverse" => stretch::style::FlexDirection::ColumnReverse,
            _ => Default::default(),
        },

        flex_wrap: match layout["flex-wrap"] {
            JsonValue::Short(ref value) if value == "nowrap" => stretch::style::FlexWrap::NoWrap,
            JsonValue::Short(ref value) if value == "wrap" => stretch::style::FlexWrap::Wrap,
            JsonValue::Short(ref value) if value == "wrap-reverse" => stretch::style::FlexWrap::WrapReverse,
            _ => Default::default(),
        },

        overflow: match layout["overflow"] {
            JsonValue::Short(ref value) if value == "visible" => stretch::style::Overflow::Visible,
            JsonValue::Short(ref value) if value == "hidden" => stretch::style::Overflow::Hidden,
            JsonValue::Short(ref value) if value == "scroll" => stretch::style::Overflow::Scroll,
            _ => Default::default(),
        },

        align_items: match layout["align-items"] {
            JsonValue::Short(ref value) if value == "flex-start" => stretch::style::AlignItems::FlexStart,
            JsonValue::Short(ref value) if value == "flex-end" => stretch::style::AlignItems::FlexEnd,
            JsonValue::Short(ref value) if value == "center" => stretch::style::AlignItems::Center,
            JsonValue::Short(ref value) if value == "baseline" => stretch::style::AlignItems::Baseline,
            JsonValue::Short(ref value) if value == "stretch" => stretch::style::AlignItems::Stretch,
            _ => Default::default(),
        },

        align_self: match layout["align-self"] {
            JsonValue::Short(ref value) if value == "auto" => stretch::style::AlignSelf::Auto,
            JsonValue::Short(ref value) if value == "flex-start" => stretch::style::AlignSelf::FlexStart,
            JsonValue::Short(ref value) if value == "flex-end" => stretch::style::AlignSelf::FlexEnd,
            JsonValue::Short(ref value) if value == "center" => stretch::style::AlignSelf::Center,
            JsonValue::Short(ref value) if value == "baseline" => stretch::style::AlignSelf::Baseline,
            JsonValue::Short(ref value) if value == "stretch" => stretch::style::AlignSelf::Stretch,
            _ => Default::default(),
        },

        align_content: match layout["align-content"] {
            JsonValue::Short(ref value) if value == "flex-start" => stretch::style::AlignContent::FlexStart,
            JsonValue::Short(ref value) if value == "flex-end" => stretch::style::AlignContent::FlexEnd,
            JsonValue::Short(ref value) if value == "center" => stretch::style::AlignContent::Center,
            JsonValue::Short(ref value) if value == "stretch" => stretch::style::AlignContent::Stretch,
            JsonValue::Short(ref value) if value == "stretch" => stretch::style::AlignContent::SpaceBetween,
            JsonValue::Short(ref value) if value == "stretch" => stretch::style::AlignContent::SpaceAround,
            _ => Default::default(),
        },

        justify_content: match layout["justify-content"] {
            JsonValue::Short(ref value) if value == "flex-start" => stretch::style::JustifyContent::FlexStart,
            JsonValue::Short(ref value) if value == "flex-end" => stretch::style::JustifyContent::FlexEnd,
            JsonValue::Short(ref value) if value == "center" => stretch::style::JustifyContent::Center,
            JsonValue::Short(ref value) if value == "stretch" => stretch::style::JustifyContent::SpaceBetween,
            JsonValue::Short(ref value) if value == "stretch" => stretch::style::JustifyContent::SpaceAround,
            JsonValue::Short(ref value) if value == "stretch" => stretch::style::JustifyContent::SpaceEvenly,
            _ => Default::default(),
        },

        position: Rect {
            start: parse_dimension(&layout["start"]),
            end: parse_dimension(&layout["end"]),
            top: parse_dimension(&layout["top"]),
            bottom: parse_dimension(&layout["bottom"]),
        },

        margin: Rect {
            start: parse_dimension(&layout["margin-start"]),
            end: parse_dimension(&layout["margin-end"]),
            top: parse_dimension(&layout["margin-top"]),
            bottom: parse_dimension(&layout["margin-bottom"]),
        },

        padding: Rect {
            start: parse_dimension(&layout["padding-start"]),
            end: parse_dimension(&layout["padding-end"]),
            top: parse_dimension(&layout["padding-top"]),
            bottom: parse_dimension(&layout["padding-bottom"]),
        },

        border: Rect {
            start: parse_dimension(&layout["border-start"]),
            end: parse_dimension(&layout["border-end"]),
            top: parse_dimension(&layout["border-top"]),
            bottom: parse_dimension(&layout["border-bottom"]),
        },

        flex_grow: layout["flex-grow"].as_f32().unwrap_or(0.0),
        flex_shrink: layout["flex-shrink"].as_f32().unwrap_or(1.0),

        flex_basis: parse_dimension(&layout["flex-basis"]),

        size: Size {
            width: parse_dimension(&layout["width"]),
            height: parse_dimension(&layout["height"]),
        },

        min_size: Size {
            width: parse_dimension(&layout["min-width"]),
            height: parse_dimension(&layout["min-height"]),
        },

        max_size: Size {
            width: parse_dimension(&layout["max-width"]),
            height: parse_dimension(&layout["max-height"]),
        },

        aspect_ratio: match layout["aspect-ratio"] {
            JsonValue::Number(value) => Number::Defined(value.into()),
            _ => Number::Undefined,
        },

        measure: Some(Box::new(move |constraint| {
            let vml_view = unsafe { &*raw_vml_view };
            vml_view.measure(constraint)
        })),
        
        children: node_children,
    };

    Root { view_node: ViewNode { vml_view, children }, stretch_node: stretch_node }
}

fn parse_dimension(json: &JsonValue) -> Dimension {
    let value = &json["value"];

    match json["unit"] {
        JsonValue::Short(ref unit) if unit == "auto" => Dimension::Auto,
        JsonValue::Short(ref unit) if unit == "points" => Dimension::Points(value.as_f32().unwrap()),
        JsonValue::Short(ref unit) if unit == "percent" => Dimension::Percent(value.as_f32().unwrap()),
        _ => Default::default(),
    }
}
