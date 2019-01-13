/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import VMLKit
import SafariServices

class ShardViewController: UIViewController {
    @IBOutlet weak var root: VMLRootView!
    
    var url: URL? = nil
    
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        
        self.root.on("open-url") {
            let url = try! $0!.asString()
            self.present(SFSafariViewController(url: URL(string: url)!), animated: true, completion: nil)
        }
        
        refresh()
    }
    
    @objc private func refresh() {
        VMLViewManager.shared.loadUrl(url: url!) { result in
            self.root.setRoot(result)
        }
    }
}
