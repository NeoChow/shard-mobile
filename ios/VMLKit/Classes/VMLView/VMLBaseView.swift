/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public class VMLBaseView: VMLView, Stateful {
    private var onTap: (() -> Void)? = nil
    private var backgroundColors: [UIControlState : UIColor] = [:]
    private var cornerRadius: BorderRadius = .Points(0)
    private var state: UIControlState = .normal
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("unsupported initializer")
    }
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = true
    }
    
    override public var frame: CGRect {
        didSet {
            updateCornerRadius()
        }
    }
    
    @objc
    private func performTap() {
        onTap?()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard onTap != nil else { return }
        set(state: .highlighted)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard onTap != nil else { return }
        set(state: point(inside: touches.first!.location(in: self), with: event) ? .highlighted : .normal)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard onTap != nil else { return }
        set(state: .normal)
        
        if point(inside: touches.first!.location(in: self), with: event) {
            onTap!()
        }
    }
    
    private func updateCornerRadius() {
        switch cornerRadius {
        case .Max:
            self.layer.cornerRadius = min(self.frame.width, self.frame.height) / 2
        case .Points(let value):
            self.layer.cornerRadius = CGFloat(value)
        }
    }
    
    public func setBorderRadius(_ radius: BorderRadius) {
        cornerRadius = radius
        self.layer.masksToBounds = true
        updateCornerRadius()
    }
    
    public func setBorderColor(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
    }
    
    public func setBorderWidth(_ width: Float) {
        self.layer.borderWidth = CGFloat(width)
    }
    
    public func setTapHandler(_ onTap: @escaping () -> Void) {
        self.onTap = onTap
    }
    
    public func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {
        backgroundColors[state] = color
        if state == self.state {
            backgroundColor = color
        }
    }
    
    public func set(state: UIControlState) {
        self.state = state
        backgroundColor = backgroundColors[state] ?? backgroundColors[.normal]
    }
}
