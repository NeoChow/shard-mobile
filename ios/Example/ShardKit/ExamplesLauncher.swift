//
//  ExamplesLauncher.swift
//  ShardKit_Example
//
//  Created by Anna Viklund on 2019-01-15.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class ExamplesLauncher: NSObject {
    let backgroundView = UIView()
    
    override init() {
        super.init()
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
}
