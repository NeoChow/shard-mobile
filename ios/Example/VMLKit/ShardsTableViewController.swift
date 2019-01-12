/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import VMLKit
import CoreData
import Alamofire

struct SampleShard {
    var title: String
    var url: String
}

class ShardsTableViewController: UITableViewController, ScanViewControllerDelegate {
    let scanVC = ScanViewController()
    var shards: [Shard] = []
    var samples = [
        SampleShard(title: "Quickstart", url: "http://localhost:3000")
    ]
    
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
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Previous shards"
        case 1:
            return "Samples"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return shards.count
        case 1:
            return samples.count
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
            let sample = samples[indexPath.row]
            cell.textLabel?.text = sample.title
            cell.detailTextLabel?.text = nil
            break
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ShardViewController {
            let shardVC = segue.destination as! ShardViewController
            
            if segue.identifier == "localhost" {
                shardVC.title =  "localhost"
                shardVC.url = URL(string:  "http://localhost:3000")
            } else {
                let indexPath = tableView.indexPathForSelectedRow!
                switch indexPath.section {
                case 0:
                    let shard = self.shards[tableView.indexPathForSelectedRow!.row]
                    shardVC.title = shard.title
                    shardVC.url = URL(string: shard.instance!)
                    break
                case 1:
                    let sample = self.samples[tableView.indexPathForSelectedRow!.row]
                    shardVC.title = sample.title
                    shardVC.url = URL(string: sample.url)
                    break
                default:
                    break
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
            url.host == "shard.visly.app"
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
