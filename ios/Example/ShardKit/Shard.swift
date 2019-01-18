/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import Foundation
import CoreData
import ShardKit

enum ShardPosition: String {
    case Top, Bottom, Center
}

extension Shard {
    var position: ShardPosition {
        get {
            return ShardPosition(rawValue: self.positionValue!)!
        }
        set {
            self.positionValue = newValue.rawValue
        }
    }
    
    convenience init(context: NSManagedObjectContext, json: JsonValue) throws {
        self.init(context: context)
        
        let values = try json.asObject()
        self.sid = try values["sid"]!.asString()
        self.title = try values["title"]!.asString()
        self.details = try values["details"]!.asString()
        self.instance = try values["url"]!.asString()
        self.positionValue = try values["settings"]!.asObject()["position"]!.asString()
        self.createdAt = Date()
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
    
    func get() throws -> [Shard] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return try context.fetch(request) as! [Shard]
    }
    
    func create(json: JsonValue) throws -> Shard {
        let values = try json.asObject()
        let instance = try values["url"]!.asString()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "instance = %@", instance)
        let result = try context.fetch(request) as! [Shard]
        
        if let previous = result.first {
            return previous
        }
        
        let new = Shard(context: context)
        appDelegate.saveContext()
        return new
    }
    
    func delete() throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
    }
}

struct ShardData {
    let url: String
    let position: String
    let title: String?
    let description: String?
    
    init(url: String, position: String, title: String?, description: String?) {
        self.title = nil
        self.description = nil
        self.url = url
        self.position = "center"
    }
    
    init(json: JsonValue) throws {
        let values = try json.asObject()
        self.url = try values["url"]!.asString()
        self.position = try values["settings"]!.asObject()["position"]!.asString()
        self.title = try values["title"]!.asString()
        self.description = try values["description"]!.asString()
    }
    
    init(shard: Shard) {
        self.url = shard.instance!
        self.position = "center"
        self.title = shard.title!
        self.description = shard.instance!
    }
}
