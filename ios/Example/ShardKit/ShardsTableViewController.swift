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

struct Example {
    let title: String
    let description: String
    let url: String
    
    init(json: JsonValue) throws {
        let values = try json.asObject()
        self.title = try values["title"]!.asString()
        self.description = try values["description"]!.asString()
        self.url = try values["url"]!.asString()
    }
}

class ShardsTableViewController: UITableViewController, ScanViewControllerDelegate {
    let scanVC = ScanViewController()
    var shards: [Shard] = []
    var examples: [Example] = []
    let backgroundView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if TARGET_OS_SIMULATOR == 0 {
            navigationItem.rightBarButtonItem = nil
        }
        
        self.addChildViewController(scanVC)
        scanVC.delegate = self
        scanVC.view.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        self.tableView.tableHeaderView = scanVC.view
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Shard")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let result = try! context.fetch(request)
        self.shards = result as! [Shard]
        
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
                    self.examples = [try Example(json: example)] + self.examples
                }
            } catch {
                self.examples = []
            }
            self.tableView.reloadData()
        }
    }
    
    func showExample() {
        if let window = UIApplication.shared.keyWindow {
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissExample)))
            
            window.addSubview(backgroundView)
            backgroundView.frame = window.frame
            backgroundView.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundView.alpha = 1
            })
        }
    }
    
    @objc func dismissExample() {
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundView.alpha = 0
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Previous shards"
        case 1:
            return "Examples"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return shards.count
        case 1:
            return examples.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shardcell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            let shard = shards[indexPath.row]
            cell.textLabel?.text = shard.title
            cell.detailTextLabel?.text = shard.instance
            break
        case 1:
            let example = examples[indexPath.row]
            cell.textLabel?.text = example.title
            cell.detailTextLabel?.text = example.description
            break
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            self.performSegue(withIdentifier: "viewShard", sender: self)
            break
        case 1:
            self.showExample()
            break
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ShardViewController {
            let shardVC = segue.destination as! ShardViewController
            
            if segue.identifier == "localhost" {
                shardVC.title =  "localhost"
                shardVC.url = URL(string:  "http://localhost:3000")
            } else {
                let indexPath = tableView.indexPathForSelectedRow!
                if (indexPath.section == 0) {
                    let shard = self.shards[tableView.indexPathForSelectedRow!.row]
                    shardVC.title = shard.title
                    shardVC.url = URL(string: shard.instance!)
                }
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
            
            self.shards = [shard] + self.shards
            self.tableView.reloadData()
            self.tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .none)
            
            self.performSegue(withIdentifier: "viewShard", sender: self)
        }
    }
}
