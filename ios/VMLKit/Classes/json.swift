/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
import Foundation
import yoga

public enum JSON {
    case Null
    case Number(Float)
    case String(String)
    case Boolean(Bool)
    case Object([String: JSON])
    case Array([JSON])
    
    public init(_ value: Any?) throws {
        switch value {
        case nil: self = .Null
        case let value as Int: self = .Number(Float(value))
        case let value as Float: self = .Number(Float(value))
        case let value as Double: self = .Number(Float(value))
        case let value as Bool: self = .Boolean(value)
        case let value as String: self = .String(value)
        case let value as [String: Any]: self = .Object(try JSON.parse(value))
        case let value as [Any]: self = .Array(try value.map({ try JSON($0) }))
        default: throw "Unexpected json, found value: \(value!) of type: \(type(of: value))"
        }
    }
    
    private static func parse(_ json: [String: Any?]) throws -> [String: JSON] {
        return try json.mapValues({ try JSON($0) })
    }
    
    public func asObject() throws -> [String: JSON] {
        switch self {
        case .Object(let value): return value
        case let value: throw "\(value) is not an object"
        }
    }
    
    public func asArray() throws -> [JSON] {
        switch self {
        case .Array(let value): return value
        case let value: throw "\(value) is not an array"
        }
    }
    
    public func asNumber() throws -> Float {
        switch self {
        case .Number(let value): return value
        case let value: throw "\(value) is not a number"
        }
    }
    
    public func asString() throws -> String {
        switch self {
        case .String(let value): return value
        case let value: throw "\(value) is not a string"
        }
    }
    
    public func asBoolean() throws -> Bool {
        switch self {
        case .Boolean(let value): return value
        case let value: throw "\(value) is not a boolean"
        }
    }
}

public extension Dictionary where Key == String, Value == JSON {
    func get<Return>(_ key: Key, _ callback: (Value) throws -> Return) rethrows -> Return {
        if let value = self[key] {
            return try callback(value)
        } else {
            return try callback(JSON.Null)
        }
    }
}

internal extension Dictionary where Key == String, Value == JSON {
    func asYGValue() throws -> YGValue {
        
        let value: Float = try get("value") {
            switch $0 {
            case .Number(let value): return value
            case let value: throw "Unexpected value: \(value)"
            }
        }
        
        return try get("unit") {
            switch $0 {
            case .String(let unit) where unit == "point": return YGValue(value: value, unit: .point)
            case .String(let unit) where unit == "pixel": return YGValue(value: value / Float(UIScreen.main.scale), unit: .point)
            case .String(let unit) where unit == "percent": return YGValue(value: value, unit: .percent)
            case let unit: throw "Unexpected unit: \(unit)"
            }
        }
    }
}

internal extension Dictionary where Key == String, Value == JSON {
    func asDimension() throws -> Float {
        
        let value: Float = try get("value") {
            switch $0 {
            case .Number(let value): return value
            case let value: throw "Unexpected value: \(value)"
            }
        }
        
        return try get("unit") {
            switch $0 {
            case .String(let unit) where unit == "point": return value
            case .String(let unit) where unit == "pixel": return value / Float(UIScreen.main.scale)
            case let unit: throw "Unexpected unit: \(unit)"
            }
        }
    }
}
