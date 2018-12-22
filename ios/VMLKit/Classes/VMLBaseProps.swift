//
//  VMLBaseProps.swift
//  VMLKit
//
//  Created by Emil Sjölander on 06/12/2018.
//

import UIKit

class VMLBaseProps {
    private let tapAction: String?
    private let borderColor: UIColor?
    private let borderWidth: Float?
    private let borderRadius: BorderRadius?
    private var backgroundColor: [UIControl.State : UIColor]
    
    init(_ props: [String: JSON]) throws {
        self.borderColor = try props.get("border-color") {
            switch $0 {
            case .Object(let value):
                return try value.get("default") {
                    switch $0 {
                    case .String(let value): return try UIColor(hex: value)
                    case let value: throw "Unexpected value for color: \(value)"
                    }
                }
            case .Null: return nil
            case let value: throw "Unexpected value for border-color: \(value)"
            }
        }
        
        self.borderWidth = try props.get("border-width") {
            switch $0 {
            case .Object(let value): return try value.asDimension()
            case .Null: return nil
            case let value: throw "Unexpected value for border-width: \(value)"
            }
        }
        
        self.borderRadius = try props.get("border-radius") {
            switch $0 {
            case .Object(let value): return .Points(try value.asDimension())
            case .String(let value) where value == "max": return .Max
            case .Null: return nil
            case let value: throw "Unexpected value for border-radius: \(value)"
            }
        }
        
        self.backgroundColor = try props.get("background-color") {
            switch $0 {
            case .Object(let value):
                var colors: [UIControl.State : UIColor] = [:]
                colors[.normal] = try value.get("default") {
                    switch $0 {
                    case .String(let value): return try UIColor(hex: value)
                    case let value: throw "Unexpected value for color: \(value)"
                    }
                }
                
                colors[.highlighted] = try value.get("pressed") {
                    switch $0 {
                    case .Null: return nil
                    case .String(let value): return try UIColor(hex: value)
                    case let value: throw "Unexpected value for color: \(value)"
                    }
                }
                
                return colors
            case .Null: return [:]
            case let value: throw "Unexpected value for background-color: \(value)"
            }
        }
        
        self.tapAction = try props.get("tap-action") {
            switch $0 {
            case .String(let value): return value
            case .Null: return nil
            case let value: throw "Unexpected value for tap-action: \(value)"
            }
        }
    }
    
    func apply(ctx: VMLContext, view: VMLView) {
        if let borderColor = self.borderColor {
            view.setBorderColor(borderColor)
        }
        
        if let borderWidth = self.borderWidth {
            view.setBorderWidth(borderWidth)
        }
        
        if let borderRadius = self.borderRadius {
            view.setBorderRadius(borderRadius)
        }
        
        for (state, color) in self.backgroundColor {
            view.setBackgroundColor(color, forState: state)
        }
        
        if let tapAction = self.tapAction {
            view.setTapHandler {
                ctx.dispatchEvent(type: "perform-action", data: ["action": JSON.String(tapAction)])
            }
        }
    }
}
