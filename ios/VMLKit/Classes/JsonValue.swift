/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
import Foundation

public enum JsonValue {
    case Null
    case Number(Float)
    case String(String)
    case Boolean(Bool)
    case Object([String: JsonValue])
    case Array([JsonValue])
    
    public init(_ value: Any?) {
        switch value {
        case nil: self = .Null
        case let value as Int: self = .Number(Float(value))
        case let value as Float: self = .Number(Float(value))
        case let value as Double: self = .Number(Float(value))
        case let value as Bool: self = .Boolean(value)
        case let value as String: self = .String(value)
        case let value as [String: Any]: self = .Object(JsonValue.parse(value))
        case let value as [Any]: self = .Array(value.map({ JsonValue($0) }))
        default: self = .Null
        }
    }
    
    private static func parse(_ json: [String: Any?]) -> [String: JsonValue] {
        return json.mapValues({ JsonValue($0) })
    }
    
    public func asObject() throws -> [String: JsonValue] {
        switch self {
        case .Object(let value): return value
        case let value: throw "\(value) is not an object"
        }
    }
    
    public func asArray() throws -> [JsonValue] {
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
    
    public func toString() -> String {
        switch self {
        case .Null: return "null"
        case let .Number(value): return "\(value)"
        case let .Boolean(value): return "\(value)"
        case let .String(value): return "\"\(value)\""
        case let .Object(values):
            var json = ""
            json.append("{")
            var i = 0
            for (key, value) in values {
                json.append("\"\(key)\":")
                json.append(value.toString())
                if i < values.count - 1 { json.append(","); i += 1 }
            }
            json.append("}")
            return json
        case let .Array(values):
            var json = ""
            json.append("[")
            var i = 0
            for value in values {
                json.append(value.toString())
                if i < values.count - 1 { json.append(","); i += 1 }
            }
            json.append("]")
            return json
        }
    }
}

public extension Dictionary where Key == String, Value == JsonValue {
    func get<Return>(_ key: Key, _ callback: (Value) throws -> Return) rethrows -> Return {
        if let value = self[key] {
            return try callback(value)
        } else {
            return try callback(JsonValue.Null)
        }
    }
}

internal extension Dictionary where Key == String, Value == JsonValue {
    func asDimension() throws -> Float {
        
        let value: Float = try get("value") {
            switch $0 {
            case .Number(let value): return value
            case let value: throw "Unexpected value: \(value)"
            }
        }
        
        return try get("unit") {
            switch $0 {
            case .String(let unit) where unit == "points": return value
            case .String(let unit) where unit == "pixels": return value / Float(UIScreen.main.scale)
            case let unit: throw "Unexpected unit: \(unit)"
            }
        }
    }
}

internal extension JsonValue {
    func asColor() throws -> VMLColor {
        switch self {
        case .String(let value): return VMLColor(default: try UIColor(hex: value), pressed: nil)
        case .Object(let value):
            return VMLColor(
                default: try UIColor(hex: value["default"]!.asString()),
                pressed: value["pressed"] != nil ? try UIColor(hex: value["pressed"]!.asString()) : nil)
        case let value: throw "Unexpected value: \(value)"
        }
    }
}
