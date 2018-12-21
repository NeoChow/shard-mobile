/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Quick
import Nimble
@testable import VMLKit

class VMLTextShadowViewSpec: QuickSpec {
    override func spec() {
        let ctx = VMLContext(config: VMLConfig.default, root: VMLRootView())
        
        it("should fail if no text is set") {
            let shadowView = VMLTextShadowView(ctx, nil)
            
            do {
                try shadowView.setProps([:])
                fail("Expected exception")
            } catch { }
        }

        it("should set text-align") {
            let shadowView = VMLTextShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "text": JSON.String("hello"),
                "text-align": JSON.String("center")
            ])

            let label = (shadowView.getView() as! VMLViewWrapper<VMLLabel>).wrapping
            expect(label.textAlignment) == .center
        }
        
        it("should set max-lines") {
            let shadowView = VMLTextShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "text": JSON.String("hello"),
                "max-lines": JSON.Number(10)
            ])
            
            let label = (shadowView.getView() as! VMLViewWrapper<VMLLabel>).wrapping
            expect(label.numberOfLines) == 10
        }
        
        it("should set font-color") {
            let shadowView = VMLTextShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "text": JSON.String("hello"),
                "font-color": JSON.Object([
                    "default": JSON.String("#F00")
                ])
            ])
            
            let label = (shadowView.getView() as! VMLViewWrapper<VMLLabel>).wrapping
            let atttribute = label.attributedText!.attribute(.foregroundColor, at: 0, effectiveRange: nil)
            expect(atttribute as! UIColor?) == UIColor.red
        }
        
        it("should set font-size") {
            let shadowView = VMLTextShadowView(ctx, nil)
            
            try! shadowView.setProps([
                "text": JSON.String("hello"),
                "font-size": JSON.Object([
                    "unit": JSON.String("point"),
                    "value": JSON.Number(15)
                ])
            ])
            
            let label = (shadowView.getView() as! VMLViewWrapper<VMLLabel>).wrapping
            let font = label.attributedText!.attribute(.font, at: 0, effectiveRange: nil) as! UIFont?
            expect(font?.pointSize) == 15
        }
    
        it("should have correct defaults") {
            let shadowView = VMLTextShadowView(ctx, nil)
            
            try! shadowView.setProps(["text": JSON.String("hello")])
            
            let label = (shadowView.getView() as! VMLViewWrapper<VMLLabel>).wrapping
            expect(label.textColor) == .black
            expect(label.font) == UIFont.systemFont(ofSize: 12)
            expect(label.numberOfLines) == -1
            expect(label.textAlignment) == .left
            expect(label.attributedText!.attribute(.font, at: 0, effectiveRange: nil) == nil) == true
            expect(label.attributedText!.attribute(.foregroundColor, at: 0, effectiveRange: nil) == nil) == true
        }
    }
}
