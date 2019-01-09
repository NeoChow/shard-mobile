/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import VMLKit

class ShardViewController: UIViewController {
    @IBOutlet weak var root: VMLRootView!
    
    var url: URL? = nil
    
    override func viewDidLoad() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        refresh()
    }
    
    @objc private func refresh() {
        VMLViewManager.shared.loadUrl(url: url!) { result in
            self.root.setRoot(result)
        }
    }
}
