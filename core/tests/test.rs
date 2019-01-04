use std::collections::HashMap;
use stretch::geometry::Rect;
use stretch::geometry::Size;
use stretch::number::Number;
use json::JsonValue;
use std::any::Any;

pub struct View {
    pub kind: String,
    pub props: HashMap<String, String>,
    pub frame: Rect<f32>,
    pub child_count: u32,
}

impl core::VMLView for View {
    fn add_child(&mut self, child: &core::VMLView) {
        self.child_count += 1;
    }

    fn set_prop(&mut self, key: &str, value: &JsonValue) {
        self.props.insert(key.to_string(), value.dump());
    }

    fn set_frame(&mut self, frame: Rect<f32>) {
        self.frame = frame;
    }

    fn measure(&self, constraints: Size<Number>) -> Size<f32> {
        Size { width: 100.0, height: 100.0 } 
    }

    fn as_any(&self) -> &Any { self }
}

pub struct ViewManager {}

impl core::VMLViewManager for ViewManager {
    fn create_view(&self, kind: &str) -> Box<core::VMLView> {
        Box::new(View {
            kind: kind.to_string(),
            props: HashMap::new(),
            frame: Rect { start: 0.0, end: 0.0, top: 0.0, bottom: 0.0 },
            child_count: 0,
        })
    }
}