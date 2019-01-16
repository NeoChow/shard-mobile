/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import ShardKit
import CoreData
import Alamofire

struct ShardData {
    let title: String
    let description: String
    let url: String
    let position: String
    
    init(json: JsonValue) throws {
        let values = try json.asObject()
        self.title = try values["title"]!.asString()
        self.description = try values["description"]!.asString()
        self.url = try values["url"]!.asString()
        self.position = try values["settings"]!.asObject()["position"]!.asString()
    }
    
    init(shard: Shard) {
        self.title = shard.title!
        self.description = shard.instance!
        self.url = shard.instance!
        self.position = "center"
    }
}

class ShardsTableViewController: UITableViewController, ScanViewControllerDelegate {
    let scanVC = ScanViewController()
    let alertLauncher = AlertLauncher()
    
    var examples: [ShardData] = []
    var shards: [ShardData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if TARGET_OS_SIMULATOR == 0 {
            navigationItem.rightBarButtonItem = nil
        }
        
        self.addChildViewController(scanVC)
        scanVC.delegate = self
        scanVC.view.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        self.tableView.tableHeaderView = scanVC.view
        alertLauncher.onDismiss = {
            self.scanVC.paused = false
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Shard")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let result = try! context.fetch(request) as! [Shard]
        
        for shard in result {
            self.shards = [ShardData(shard: shard)] + self.shards
        }
        
        loadExamples()
    }
    
    func fetchData(url: URL, onComplete: @escaping (JsonValue) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { data, response, httpError in
            let json = JsonValue(try! JSONSerialization.jsonObject(with: data!, options: []))
            DispatchQueue.main.async { onComplete(json) }
        }
        task.resume()
    }
    
    func loadExamples() {
        fetchData(url: URL(string: "https://playground.shardlib.com/api/shards/examples")!) { json in
            do {
                let examples = try json.asArray()
                for example in examples {
                    self.examples = [try ShardData(json: example)] + self.examples
                }
            } catch {
                self.examples = []
            }
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Examples"
        case 1:
            return "Previous shards"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return examples.count
        case 1:
            return shards.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shardcell", for: indexPath)
        let collection = indexPath.section == 0 ? examples : shards
        let shard = collection[indexPath.row]
        
        cell.textLabel?.text = shard.title
        cell.detailTextLabel?.text = shard.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let collection = indexPath.section == 0 ? examples : shards
        let shard = collection[indexPath.row]
        self.alertLauncher.load(withShard: shard)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ShardViewController {
            let shardVC = segue.destination as! ShardViewController
            
            if segue.identifier == "localhost" {
                shardVC.title =  "localhost"
                shardVC.url = URL(string:  "http://localhost:3000")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scanVC.paused = false
    }
    
    // MARK: - ScanViewControllerDelegate
    
    func didScan(url: URL) {
        guard
            url.host == "playground.shardlib.com"
        else {
            return
        }
        
        self.scanVC.paused = true
        
        Alamofire.request(url).responseJSON { response in
            guard
                response.error == nil,
                response.response != nil,
                response.response!.statusCode <= 300,
                let json = response.result.value as? Dictionary<String, Any>,
                let title = json["title"] as? String,
                let instance = json["url"] as? String
            else {
                return
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let shard = Shard(context: context)
            shard.title = title
            shard.createdAt = Date()
            shard.instance = instance
            shard.revision = 1
            appDelegate.saveContext()
            
            let shardData = ShardData(shard: shard)
            self.shards = [shardData] + self.shards
            self.tableView.reloadData()
            
            self.alertLauncher.load(withShard: shardData)
        }
    }
}
