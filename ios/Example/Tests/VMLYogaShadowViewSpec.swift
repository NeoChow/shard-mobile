/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
import yoga
@testable import VMLKit

class VMLYogaShadowViewSpec: QuickSpec {
    override func spec() {
        let ctx = VMLContext(config: VMLConfig.default, root: VMLRootView())
        
        it("should fail if children is undefined") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            do {
                try shadowView.setProps([:])
                fail("Expected exception")
            } catch { }
        }
        
        it("should have correct defaults") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([])
            ])
            
            expect(YGNodeStyleGetFlexDirection(shadowView.node)) == .row
            expect(YGNodeStyleGetFlexWrap(shadowView.node)) == .noWrap
            expect(YGNodeStyleGetAlignItems(shadowView.node)) == .stretch
            expect(YGNodeStyleGetAlignContent(shadowView.node)) == .stretch
            expect(YGNodeStyleGetJustifyContent(shadowView.node)) == .flexStart
            expect(YGNodeStyleGetPadding(shadowView.node, .all).unit) == .undefined
            expect(YGNodeStyleGetPadding(shadowView.node, .start).unit) == .undefined
            expect(YGNodeStyleGetPadding(shadowView.node, .end).unit) == .undefined
            expect(YGNodeStyleGetPadding(shadowView.node, .top).unit) == .undefined
            expect(YGNodeStyleGetPadding(shadowView.node, .bottom).unit) == .undefined
        }
        
        it("should instantiate children") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([:])
                    ])
                ])
            ])
            
            expect(shadowView.children.count) == 1
            expect(type(of: shadowView.children[0].1) == VMLYogaShadowView.self) == true
        }
        
        it("should have correct children defaults") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([:])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetWidth(child).unit) == .auto
            expect(YGNodeStyleGetMinWidth(child).unit) == .undefined
            expect(YGNodeStyleGetMaxWidth(child).unit) == .undefined
            expect(YGNodeStyleGetHeight(child).unit) == .auto
            expect(YGNodeStyleGetMinHeight(child).unit) == .undefined
            expect(YGNodeStyleGetMaxHeight(child).unit) == .undefined
            
            expect(YGNodeStyleGetMargin(child, .all).unit) == .undefined
            expect(YGNodeStyleGetMargin(child, .start).unit) == .undefined
            expect(YGNodeStyleGetMargin(child, .end).unit) == .undefined
            expect(YGNodeStyleGetMargin(child, .top).unit) == .undefined
            expect(YGNodeStyleGetMargin(child, .bottom).unit) == .undefined
            
            expect(YGNodeStyleGetFlexGrow(child)) == 0
            expect(YGNodeStyleGetFlexShrink(child)) == 1
            expect(YGNodeStyleGetFlexBasis(child).unit) == .auto
            
            expect(YGNodeStyleGetAlignSelf(child)) == .auto
            expect(YGNodeStyleGetAspectRatio(child)) == YGUndefined
        }
        
        it("should set flex-direction") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "flex-direction": JSON.String("column")
            ])
            
            expect(YGNodeStyleGetFlexDirection(shadowView.node)) == .column
        }
        
        it("should set flex-wrap") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "flex-wrap": JSON.String("wrap")
            ])
            
            expect(YGNodeStyleGetFlexWrap(shadowView.node)) == .wrap
        }
        
        it("should set align-items") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "align-items": JSON.String("center")
            ])
            
            expect(YGNodeStyleGetAlignItems(shadowView.node)) == .center
        }
        
        it("should set align-content") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "align-content": JSON.String("center")
            ])
            
            expect(YGNodeStyleGetAlignContent(shadowView.node)) == .center
        }
        
        it("should set justify-content") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "justify-content": JSON.String("center")
            ])
            
            expect(YGNodeStyleGetJustifyContent(shadowView.node)) == .center
        }
        
        it("should set padding") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "padding": JSON.Object([
                    "unit": JSON.String("percent"),
                    "value": JSON.Number(100)
                ])
            ])
            
            expect(YGNodeStyleGetPadding(shadowView.node, .all).value) == 100
            expect(YGNodeStyleGetPadding(shadowView.node, .all).unit) == .percent
        }
        
        it("should set padding-start") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "padding-start": JSON.Object([
                    "unit": JSON.String("point"),
                    "value": JSON.Number(100)
                ])
            ])
            
            expect(YGNodeStyleGetPadding(shadowView.node, .start).value) == 100
            expect(YGNodeStyleGetPadding(shadowView.node, .start).unit) == .point
        }
        
        it("should set padding-end") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "padding-end": JSON.Object([
                    "unit": JSON.String("point"),
                    "value": JSON.Number(100)
                ])
            ])
            
            expect(YGNodeStyleGetPadding(shadowView.node, .end).value) == 100
            expect(YGNodeStyleGetPadding(shadowView.node, .end).unit) == .point
        }
        
        it("should set padding-top") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "padding-top": JSON.Object([
                    "unit": JSON.String("point"),
                    "value": JSON.Number(100)
                ])
            ])
            
            expect(YGNodeStyleGetPadding(shadowView.node, .top).value) == 100
            expect(YGNodeStyleGetPadding(shadowView.node, .top).unit) == .point
        }
        
        it("should set padding-bottom") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([]),
                "padding-bottom": JSON.Object([
                    "unit": JSON.String("point"),
                    "value": JSON.Number(100)
                ])
            ])
            
            expect(YGNodeStyleGetPadding(shadowView.node, .bottom).value) == 100
            expect(YGNodeStyleGetPadding(shadowView.node, .bottom).unit) == .point
        }
        
        it("should set width on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "width": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetWidth(child).value) == 100
            expect(YGNodeStyleGetWidth(child).unit) == .point
        }
        
        it("should set min-width on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "min-width": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetMinWidth(child).value) == 100
            expect(YGNodeStyleGetMinWidth(child).unit) == .point
        }
        
        it("should set max-width on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "max-width": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetMaxWidth(child).value) == 100
            expect(YGNodeStyleGetMaxWidth(child).unit) == .point
        }
        
        it("should set height on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "height": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetHeight(child).value) == 100
            expect(YGNodeStyleGetHeight(child).unit) == .point
        }
        
        it("should set min-height on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "min-height": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetMinHeight(child).value) == 100
            expect(YGNodeStyleGetMinHeight(child).unit) == .point
        }
        
        it("should set max-height on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "max-height": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetMaxHeight(child).value) == 100
            expect(YGNodeStyleGetMaxHeight(child).unit) == .point
        }
        
        it("should set margin on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "margin": JSON.String("auto")
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetMargin(child, .all).unit) == .auto
        }
        
        it("should set margin-start on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "margin-start": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetMargin(child, .start).value) == 100
            expect(YGNodeStyleGetMargin(child, .start).unit) == .point
        }
        
        it("should set margin-end on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "margin-end": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetMargin(child, .end).value) == 100
            expect(YGNodeStyleGetMargin(child, .end).unit) == .point
        }
        
        it("should set margin-top on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "margin-top": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetMargin(child, .top).value) == 100
            expect(YGNodeStyleGetMargin(child, .top).unit) == .point
        }
        
        it("should set margin-bottom on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "margin-bottom": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetMargin(child, .bottom).value) == 100
            expect(YGNodeStyleGetMargin(child, .bottom).unit) == .point
        }
        
        it("should set flex-grow on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "flex-grow": JSON.Number(2)
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetFlexGrow(child)) == 2
        }
        
        it("should set flex-shrink on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "flex-shrink": JSON.Number(2)
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetFlexShrink(child)) == 2
        }
        
        it("should set flex-basis on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "flex-basis": JSON.Object([
                                "unit": JSON.String("point"),
                                "value": JSON.Number(100)
                            ])
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetFlexBasis(child).value) == 100
            expect(YGNodeStyleGetFlexBasis(child).unit) == .point
        }
        
        it("should set align-self on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "align-self": JSON.String("center")
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetAlignSelf(child)) == .center
        }
        
        it("should set aspect-ratio on child") {
            let shadowView = VMLYogaShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "children": JSON.Array([
                    JSON.Object([
                        "kind": JSON.String("flexbox"),
                        "props": JSON.Object(["children": JSON.Array([])]),
                        "layout": JSON.Object([
                            "aspect-ratio": JSON.Number(1)
                        ])
                    ])
                ])
            ])
            
            let child = shadowView.children[0].0
            expect(YGNodeStyleGetAspectRatio(child)) == 1
        }
    }
}
