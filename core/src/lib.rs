/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
use stretch::geometry::Rect;
use stretch::geometry::Size;
use stretch::number::Number;
use stretch::style::Dimension;

use json::JsonValue;
use simple_error::SimpleError;
use std::any::Any;

pub trait ShardView: Any {
    fn add_child(&mut self, child: &ShardView) -> Result<(), SimpleError>;
    fn set_prop(&mut self, key: &str, value: &JsonValue) -> Result<(), SimpleError>;
    fn set_frame(&mut self, frame: Rect<f32>) -> Result<(), SimpleError>;
    fn measure(&self, constraints: Size<Number>) -> Result<Size<f32>, SimpleError>;
    fn as_any(&self) -> &Any;
}

pub trait ShardViewManager {
    fn create_view(&self, context: &Any, kind: &str) -> Result<Box<ShardView>, SimpleError>;
}

pub struct ViewNode {
    pub shard_view: Box<ShardView>,
    pub children: Vec<ViewNode>,
}

pub struct Root {
    pub view_node: ViewNode,
    pub stretch_node: stretch::style::Node,
}

impl Root {
    pub fn measure(&mut self, size: Size<Number>) -> Result<(), SimpleError> {
        set_frame(&mut self.view_node, &stretch::compute(&self.stretch_node, size)?)
    }
}

fn set_frame(view_node: &mut ViewNode, layout: &stretch::layout::Node) -> Result<(), SimpleError> {
    view_node.shard_view.set_frame(Rect {
        start: layout.location.x,
        end: layout.location.x + layout.size.width,
        top: layout.location.y,
        bottom: layout.location.y + layout.size.height,
    })?;

    for i in 0..view_node.children.len() {
        let view_node = &mut view_node.children[i];
        let layout = &layout.children[i];
        set_frame(view_node, layout)?;
    }

    Ok(())
}

pub fn render_root(platform: &ShardViewManager, context: &Any, json: &str) -> Result<Root, SimpleError> {
    match json::parse(json) {
        Ok(json) => render(platform, context, &json["root"]),
        Err(err) => Err(SimpleError::from(err)),
    }
}

fn render(platform: &ShardViewManager, context: &Any, json: &JsonValue) -> Result<Root, SimpleError> {
    let mut shard_view = match json["kind"].as_str() {
        Some(kind) => platform.create_view(context, kind)?,
        None => return Err(SimpleError::new("expected kind")),
    };

    for (key, value) in json["props"].entries() {
        shard_view.set_prop(key, value)?
    }

    let mut children: Vec<ViewNode> = vec![];
    let mut node_children: Vec<stretch::style::Node> = vec![];

    for child in json["children"].members() {
        let root = render(platform, context, child)?;
        children.push(root.view_node);
        node_children.push(root.stretch_node);
    }

    let raw_shard_view = &*shard_view as *const ShardView;

    for child in &children {
        shard_view.add_child(&*child.shard_view)?;
    }

    let layout = match json["layout"] {
        JsonValue::Object(ref value) => value,
        _ => return Err(SimpleError::new("expected layout")),
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
            JsonValue::Short(ref value) if value == "rtl" => stretch::style::Direction::RTL,
            JsonValue::Short(ref value) if value == "ltr" => stretch::style::Direction::LTR,
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
            JsonValue::Short(ref value) if value == "space-between" => stretch::style::AlignContent::SpaceBetween,
            JsonValue::Short(ref value) if value == "space-around" => stretch::style::AlignContent::SpaceAround,
            _ => Default::default(),
        },

        justify_content: match layout["justify-content"] {
            JsonValue::Short(ref value) if value == "flex-start" => stretch::style::JustifyContent::FlexStart,
            JsonValue::Short(ref value) if value == "flex-end" => stretch::style::JustifyContent::FlexEnd,
            JsonValue::Short(ref value) if value == "center" => stretch::style::JustifyContent::Center,
            JsonValue::Short(ref value) if value == "space-between" => stretch::style::JustifyContent::SpaceBetween,
            JsonValue::Short(ref value) if value == "space-around" => stretch::style::JustifyContent::SpaceAround,
            JsonValue::Short(ref value) if value == "space-evenly" => stretch::style::JustifyContent::SpaceEvenly,
            _ => Default::default(),
        },

        position: Rect {
            start: parse_dimension(&layout["start"], Dimension::Undefined)?,
            end: parse_dimension(&layout["end"], Dimension::Undefined)?,
            top: parse_dimension(&layout["top"], Dimension::Undefined)?,
            bottom: parse_dimension(&layout["bottom"], Dimension::Undefined)?,
        },

        margin: Rect {
            start: parse_dimension(&layout["margin-start"], parse_dimension(&layout["margin"], Dimension::Undefined)?)?,
            end: parse_dimension(&layout["margin-end"], parse_dimension(&layout["margin"], Dimension::Undefined)?)?,
            top: parse_dimension(&layout["margin-top"], parse_dimension(&layout["margin"], Dimension::Undefined)?)?,
            bottom: parse_dimension(
                &layout["margin-bottom"],
                parse_dimension(&layout["margin"], Dimension::Undefined)?,
            )?,
        },

        padding: Rect {
            start: parse_dimension(
                &layout["padding-start"],
                parse_dimension(&layout["padding"], Dimension::Undefined)?,
            )?,
            end: parse_dimension(&layout["padding-end"], parse_dimension(&layout["padding"], Dimension::Undefined)?)?,
            top: parse_dimension(&layout["padding-top"], parse_dimension(&layout["padding"], Dimension::Undefined)?)?,
            bottom: parse_dimension(
                &layout["padding-bottom"],
                parse_dimension(&layout["padding"], Dimension::Undefined)?,
            )?,
        },

        border: Rect {
            start: parse_dimension(&layout["border-start"], parse_dimension(&layout["border"], Dimension::Undefined)?)?,
            end: parse_dimension(&layout["border-end"], parse_dimension(&layout["border"], Dimension::Undefined)?)?,
            top: parse_dimension(&layout["border-top"], parse_dimension(&layout["border"], Dimension::Undefined)?)?,
            bottom: parse_dimension(
                &layout["border-bottom"],
                parse_dimension(&layout["border"], Dimension::Undefined)?,
            )?,
        },

        flex_grow: layout["flex-grow"].as_f32().unwrap_or(0.0),
        flex_shrink: layout["flex-shrink"].as_f32().unwrap_or(1.0),

        flex_basis: parse_dimension(&layout["flex-basis"], Dimension::Auto)?,

        size: Size {
            width: parse_dimension(&layout["width"], Dimension::Auto)?,
            height: parse_dimension(&layout["height"], Dimension::Auto)?,
        },

        min_size: Size {
            width: parse_dimension(&layout["min-width"], Dimension::Auto)?,
            height: parse_dimension(&layout["min-height"], Dimension::Auto)?,
        },

        max_size: Size {
            width: parse_dimension(&layout["max-width"], Dimension::Auto)?,
            height: parse_dimension(&layout["max-height"], Dimension::Auto)?,
        },

        aspect_ratio: match layout["aspect-ratio"] {
            JsonValue::Number(value) => Number::Defined(value.into()),
            _ => Number::Undefined,
        },

        measure: Some(Box::new(move |constraint| {
            let shard_view = unsafe { &*raw_shard_view };
            Ok(shard_view.measure(constraint))
        })),

        children: node_children,

        ..Default::default()
    };

    Ok(Root { view_node: ViewNode { shard_view, children }, stretch_node })
}

fn parse_dimension(json: &JsonValue, default: Dimension) -> Result<Dimension, SimpleError> {
    let value = &json["value"];

    match json["unit"] {
        JsonValue::Short(ref unit) if unit == "auto" => Ok(Dimension::Auto),
        JsonValue::Short(ref unit) if unit == "points" => match value.as_f32() {
            Some(value) => Ok(Dimension::Points(value)),
            None => Err(SimpleError::new("expected float")),
        },
        JsonValue::Short(ref unit) if unit == "percent" => match value.as_f32() {
            Some(value) => Ok(Dimension::Percent(value)),
            None => Err(SimpleError::new("expected float")),
        },
        _ => Ok(default),
    }
}
