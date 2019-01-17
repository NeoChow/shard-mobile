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
import SafariServices

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

class ShardsTableViewController: UITableViewController, ScanViewControllerDelegate, AlertLauncherDelegate {
    let scanVC = ScanViewController()
    let alertLauncher = AlertLauncher()
    
    var examples: [ShardData] = []
    var previous: [ShardData] = []
    
    @IBAction func onDevButtonPressed(_ sender: UIBarButtonItem) {
        let shard = ShardData(
            url: "http://localhost:3000",
            position: "center",
            title: nil,
            description: nil
        )
        alertLauncher.load(withShard: shard)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if TARGET_OS_SIMULATOR == 0 {
            navigationItem.rightBarButtonItem = nil
        }
        
        self.addChildViewController(scanVC)
        scanVC.delegate = self
        scanVC.view.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        self.tableView.tableHeaderView = scanVC.view
        
        alertLauncher.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Shard")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let result = try! context.fetch(request) as! [Shard]
        
        for shard in result {
            self.previous = [ShardData(shard: shard)] + self.previous
        }
        
        loadExamples()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scanVC.paused = false
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
    
    @objc func clearStoredShards() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Shard")
        
        if let result = try? context.fetch(request) as! [Shard] {
            for object in result {
                context.delete(object)
            }
            appDelegate.saveContext()
            self.previous = []
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewController
    
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
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == 1 && previous.count > 0) ? 60 : 20
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 && previous.count > 0 {
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
            
            let clearButton = UIButton()
            clearButton.setTitle("Clear", for: .normal)
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            clearButton.layer.borderColor = UIColor.black.cgColor
            clearButton.setTitleColor(.black, for: .normal)
            clearButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .highlighted)
            clearButton.addTarget(self, action: #selector(clearStoredShards), for: .touchUpOutside)
            
            clearButton.translatesAutoresizingMaskIntoConstraints = false
            footer.addSubview(clearButton)
            clearButton.centerYAnchor.constraint(equalTo: footer.layoutMarginsGuide.centerYAnchor).isActive = true
            clearButton.trailingAnchor.constraint(equalTo: footer.layoutMarginsGuide.trailingAnchor).isActive = true
            
            return footer
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return examples.count
        case 1:
            return previous.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shardcell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            let shard = examples[indexPath.row]
            cell.textLabel?.text = shard.title
            cell.detailTextLabel?.text = shard.description
            break
        case 1:
            let shard = previous[indexPath.row]
            cell.textLabel?.text = shard.title
            cell.detailTextLabel?.text = shard.description
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
            let shard = examples[indexPath.row]
            self.alertLauncher.load(withShard: shard)
            break
        case 1:
            let shard = previous[indexPath.row]
            self.alertLauncher.load(withShard: shard)
            break
        default:
            break
        }
    }
    
    // MARK: - ScanViewControllerDelegate
    
    func didScan(url: URL) {
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
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Shard")
            request.predicate = NSPredicate(format: "instance = %@", instance)
            let result = try! context.fetch(request) as! [Shard]
            
            if (result.count > 0) {
                self.alertLauncher.load(withShard: ShardData(shard: result.first!))
            } else {
                let new = Shard(context: context)
                new.title = title
                new.createdAt = Date()
                new.instance = instance
                new.revision = 1
                appDelegate.saveContext()
                
                let shard = ShardData(shard: new)
                self.previous = [shard] + self.previous
                self.tableView.reloadData()
                
                self.alertLauncher.load(withShard: shard)
            }
        }
    }
    
    // MARK: - ScanViewControllerDelegate

    func didDismiss() {
        self.scanVC.paused = false
    }
    
    func didOpenUrl(_ url: URL) {
        self.present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
}
