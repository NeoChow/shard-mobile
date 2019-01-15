//
//  ExamplesLauncher.swift
//  ShardKit_Example
//
//  Created by Anna Viklund on 2019-01-15.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import ShardKit

class ExamplesLauncher: NSObject {
    let backgroundView = UIView()
    let rootView = ShardRootView()
    
    var example: Example? = nil
    var initAlpha: CGFloat? = nil
    var finalAlpha: CGFloat? = nil
    var initY: CGFloat? = nil
    var finalY: CGFloat? = nil
    
    override init() {
        super.init()
    }
    
    func load(_ example: Example) {
        self.example = example
        let url = URL(string: example.url)
        ShardViewManager.shared.loadUrl(url: url!) { result in
            self.showExample(withContent: result)
        }
    }
    
    func showExample(withContent content: ShardRoot) {
        if let window = UIApplication.shared.keyWindow {
            setupBackgroundView(inWindow: window)
            
            window.addSubview(rootView)
            rootView.setRoot(content)
            
            let size = content.measure(width: window.frame.width, height: window.frame.height)
            
            switch example!.position {
            case "top":
                initY = 0 - size.height
                finalY = 0
                initAlpha = 1
                finalAlpha = 1
                break
            case "bottom":
                initY = window.frame.height
                finalY = window.frame.height - size.height
                initAlpha = 1
                finalAlpha = 1
                break
            default:
                initY = (window.frame.height - size.height) / 2
                finalY = self.initY
                initAlpha = 0
                finalAlpha = 1
                break
            }
            
            rootView.alpha = initAlpha!
            
            rootView.frame = CGRect(
                x: 0,
                y: initY!,
                width: size.width,
                height: size.height
            )
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView.alpha = 1
                self.rootView.alpha = self.finalAlpha!
                self.rootView.frame = CGRect(
                    x: 0,
                    y: self.finalY!,
                    width: self.rootView.frame.size.width,
                    height: self.rootView.frame.size.height
                )
            }, completion: nil)
        }
    }
    
    func setupBackgroundView(inWindow window: UIWindow) {
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.alpha = 0
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissExample)))
        
        window.addSubview(backgroundView)
        backgroundView.frame = window.frame
    }
    
    @objc func dismissExample() {
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
    }
}
