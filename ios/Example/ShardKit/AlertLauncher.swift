/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import ShardKit

protocol AlertLauncherDelegate {
    func didDismiss()
    func didOpenUrl(_ url: URL)
}

class AlertLauncher: NSObject {
    private let backgroundView = UIView()
    private let rootView = ShardRootView()
    
    var delegate: AlertLauncherDelegate?
    
    private var initAlpha: CGFloat? = nil
    private var finalAlpha: CGFloat? = nil
    private var initY: CGFloat? = nil
    private var finalY: CGFloat? = nil
    
    override init() {
        super.init()
        
        self.rootView.on("open-url") { value in
            self.dismissAlert()
            let url = try! value!.asString()
            self.delegate?.didOpenUrl(URL(string: url)!)
        }
        
        self.rootView.on("dismiss-alert") { _ in
            self.dismissAlert()
        }
    }
    
    public func load(withShard shard: ShardData) {
        let url = URL(string: shard.url)
        ShardViewManager.shared.loadUrl(url: url!) { result in
            self.showAlert(withContent: result, withPosition: shard.position)
        }
    }
    
    private func showAlert(withContent content: ShardRoot, withPosition position: String) {
        if let window = UIApplication.shared.keyWindow {
            setupBackgroundView(inWindow: window)
            
            window.addSubview(rootView)
            rootView.setRoot(content)
            
            var safeFrame = window.safeAreaLayoutGuide.layoutFrame
            
            if (position == "center") {
                let inset = window.layoutMargins.right + window.layoutMargins.left
                safeFrame = safeFrame.insetBy(
                    dx: inset,
                    dy: inset
                )
            }
            
            let size = content.measure(width: safeFrame.width, height: safeFrame.height)
            
            switch position {
            case "top":
                initY = window.frame.minY - size.height
                finalY = safeFrame.minY
                initAlpha = 1
                finalAlpha = 1
                break
            case "bottom":
                initY = window.frame.maxY
                finalY = safeFrame.maxY - size.height
                initAlpha = 1
                finalAlpha = 1
                break
            default:
                initY = safeFrame.midY - (size.height / 2)
                finalY = self.initY
                initAlpha = 0
                finalAlpha = 1
                break
            }
            
            rootView.alpha = initAlpha!
            rootView.frame = CGRect(
                x: safeFrame.minX,
                y: initY!,
                width: size.width,
                height: size.height
            )
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView.alpha = 1
                self.rootView.alpha = self.finalAlpha!
                self.rootView.frame = CGRect(
                    x: self.rootView.frame.minX,
                    y: self.finalY!,
                    width: self.rootView.frame.size.width,
                    height: self.rootView.frame.size.height
                )
            }, completion: nil)
        }
    }
    
    private func setupBackgroundView(inWindow window: UIWindow) {
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.alpha = 0
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlert)))
        
        window.addSubview(backgroundView)
        backgroundView.frame = window.frame
    }
    
    @objc private func dismissAlert() {
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundView.alpha = 0
            self.rootView.alpha = self.initAlpha!
            self.rootView.frame = CGRect(
                x: self.rootView.frame.minX,
                y: self.initY!,
                width: self.rootView.frame.width,
                height: self.rootView.frame.height
            )
        })
        
        delegate?.didDismiss()
    }
}
