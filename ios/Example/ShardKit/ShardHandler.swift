/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import CoreData
import ShardKit

enum ShardType: Int32 {
    case Default, Example
}

enum ShardPosition: String {
    case Top = "top"
    case Bottom = "bottom"
    case Center = "center"
}

extension Shard {
    var type: ShardType {
        get {
            return ShardType(rawValue: self.typeValue) ?? .Default
        }
        set {
            self.typeValue = newValue.rawValue
        }
    }
    
    var position: ShardPosition {
        get {
            return ShardPosition(rawValue: self.positionValue ?? "center") ?? .Center
        }
        set {
            self.positionValue = newValue.rawValue
        }
    }
    
    convenience init(context: NSManagedObjectContext, json: JsonValue) throws {
        self.init(context: context)
        
        self.createdAt = Date()
        self.updatedAt = createdAt
        
        try self.setValues(json: json)
    }
    
    func setValues(json: JsonValue) throws {
        let values = try json.asObject()
        
        self.id = try values["id"]!.asString()
        self.title = try values["title"]!.asString()
        self.instance = try values["url"]!.asString()
        self.positionValue = try values["settings"]!.asObject()["position"]!.asString()
        
        self.details = try values["description"]?.asString()
    }
}

class ShardHandler: NSObject {
    let entityName = "Shard"
    let appDelegate: AppDelegate
    let context: NSManagedObjectContext
    
    override init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        super.init()
    }
    
    func get(type: ShardType) throws -> [Shard] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        request.predicate = NSPredicate(format: "typeValue = %d", type.rawValue)
        return try context.fetch(request) as! [Shard]
    }
    
    func create(json: JsonValue, type: ShardType) throws -> Shard {
        let values = try json.asObject()
        let id = try values["id"]!.asString()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "id = %@", id)
        let result = try context.fetch(request) as! [Shard]
        
        if let previous = result.first {
            try previous.setValues(json: json)
            previous.type = type
            previous.updatedAt = Date()
            appDelegate.saveContext()
            
            return previous
        }
        
        let new = try Shard(context: context, json: json)
        new.type = type
        appDelegate.saveContext()
        
        return new
    }
    
    func delete(type: ShardType) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "typeValue = %d", type.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
    }
}
