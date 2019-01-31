/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import ShardKit
import SafariServices

class ShardsTableViewController: UITableViewController, ScanViewControllerDelegate, AlertLauncherDelegate {
    let SECTION_EXAMPLES = 0
    let SECTION_PREVIOUS = 1
    
    let scanVC = ScanViewController()
    let alertLauncher = AlertLauncher()
    let shardHandler = ShardHandler()
    
    var examples: [Shard] = []
    var previous: [Shard] = []
    
    @IBAction func onDevButtonPressed(_ sender: UIBarButtonItem) {
        let url = URL(string: "http://localhost:3000")
        self.alertLauncher.load(withUrl: url!)
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
        
        do {
            previous = try shardHandler.get(type: .Default)
            examples = try shardHandler.get(type: .Example).reversed()
            
            self.tableView.reloadData()
        } catch {
            didRecieveError("Unexpected error.", error.localizedDescription)
        }
        
        loadExamples()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.scanVC.paused = false
    }
    
    func fetchData(url: URL, onComplete: @escaping (Result<JsonValue>) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { data, response, httpError in
            guard httpError == nil else {
                DispatchQueue.main.async { onComplete(Result.Failure(httpError!)) }
                
                return
            }
            
            do {
                let json = JsonValue(try JSONSerialization.jsonObject(with: data!, options: []))
                DispatchQueue.main.async { onComplete(Result.Success(json)) }
            } catch let error {
                DispatchQueue.main.async { onComplete(Result.Failure(error)) }
            }
        }
        
        task.resume()
    }
    
    func loadExamples() {
        fetchData(url: URL(string: "https://playground.shardlib.com/api/shards/examples")!) { result in
            let storedExamples = self.examples
            
            switch(result) {
            case .Success(let json):
                do {
                    self.examples = []
                    let result = try json.asArray()
                    for json in result {
                        let shard = try self.shardHandler.create(json: json, type: .Example)
                        self.examples = self.examples + [shard]
                    }
                } catch {
                    print("Unexpected error. \(error.localizedDescription)")
                    self.examples = storedExamples
                }
            case .Failure(let error):
                print("Unexpected error. \(error.localizedDescription)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func onClearButtonPressed() {
        let clearAlert = UIAlertController(title: "Are you sure you want to clear previous shards?", message: nil, preferredStyle: .alert)
        
        clearAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            do {
                try self.shardHandler.delete(type: .Default)
                self.previous = []
                self.tableView.reloadData()
            } catch {
                self.didRecieveError("Unexpected error.", error.localizedDescription)
            }
        }))
        
        clearAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(clearAlert, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_EXAMPLES:
            return "Examples"
        case SECTION_PREVIOUS:
            return "My shards"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == SECTION_PREVIOUS && previous.count > 0 ? 60 : 20
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == SECTION_PREVIOUS && previous.count > 0 {
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
            
            let clearButton = UIButton(type: .system)
            clearButton.setTitle("Clear", for: .normal)
            clearButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            clearButton.addTarget(self, action: #selector(onClearButtonPressed), for: .touchUpInside)
            
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
        case SECTION_EXAMPLES:
            return examples.count
        case SECTION_PREVIOUS:
            return previous.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shardcell", for: indexPath)
        
        switch indexPath.section {
        case SECTION_EXAMPLES:
            let shard = examples[indexPath.row]
            cell.textLabel?.text = shard.title
            cell.detailTextLabel?.text = shard.details ?? shard.instance
            break
        case SECTION_PREVIOUS:
            let shard = previous[indexPath.row]
            cell.textLabel?.text = shard.title
            cell.detailTextLabel?.text = shard.details ?? shard.instance
            break
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case SECTION_EXAMPLES:
            let shard = examples[indexPath.row]
            self.alertLauncher.load(withShard: shard)
            break
        case SECTION_PREVIOUS:
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
        
        fetchData(url: url) { result in
            switch(result) {
            case .Success(let json):
                do {
                    let new = try self.shardHandler.create(json: json, type: .Default)
                    
                    let updated = try self.shardHandler.get(type: .Default)
                    self.previous = updated
                    self.tableView.reloadData()
                    
                    self.alertLauncher.load(withShard: new)
                } catch {
                    self.didRecieveError("Could not load Shard.", error.localizedDescription)
                }
            case .Failure(let error):
                self.didRecieveError("Could not load Shard.", error.localizedDescription)
            }
        }
    }
    
    // MARK: - AlertLauncherDelegate
    
    func didDismiss() {
        self.scanVC.paused = false
    }
    
    func didOpenUrl(_ url: URL) {
        self.present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
    
    func didRecieveError(_ title: String, _ message: String) {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            self.scanVC.paused = false
        }))
        self.present(errorAlert, animated: true, completion: nil)
    }
}
