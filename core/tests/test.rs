/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
use json::JsonValue;
use std::any::Any;
use std::collections::HashMap;
use stretch::geometry::Rect;
use stretch::geometry::Size;
use stretch::number::*;

pub struct View {
    pub kind: String,
    pub props: HashMap<String, String>,
    pub frame: Rect<f32>,
    pub child_count: u32,
}

impl core::ShardView for View {
    fn add_child(&mut self, _: &core::ShardView) {
        self.child_count += 1;
    }

    fn set_prop(&mut self, key: &str, value: &JsonValue) {
        self.props.insert(key.to_string(), value.dump());
    }

    fn set_frame(&mut self, frame: Rect<f32>) {
        self.frame = frame;
    }

    fn measure(&self, constraints: Size<Number>) -> Size<f32> {
        Size { width: constraints.width.or_else(100.0), height: constraints.height.or_else(100.0) }
    }

    fn as_any(&self) -> &Any {
        self
    }
}

pub struct ViewManager {}

impl core::ShardViewManager for ViewManager {
    fn create_view(&self, _: &Any, kind: &str) -> Box<core::ShardView> {
        Box::new(View {
            kind: kind.to_string(),
            props: HashMap::new(),
            frame: Rect { start: 0.0, end: 0.0, top: 0.0, bottom: 0.0 },
            child_count: 0,
        })
    }
}
