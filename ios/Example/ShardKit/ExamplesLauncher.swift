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
    let exampleView = UIView()
    
    override init() {
        super.init()
    }
    
    func showExample() {
        if let window = UIApplication.shared.keyWindow {
            setupBackgroundView(inWindow: window)
            
            exampleView.backgroundColor = UIColor.white
            
            let exampleWidth = window.frame.width
            let exampleHeight: CGFloat = 128
            let initY = window.frame.height
            let finalY = window.frame.height - exampleHeight
            
            window.addSubview(exampleView)
            exampleView.frame = CGRect(
                x: 0,
                y: initY,
                width: exampleWidth,
                height: exampleHeight
            )
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backgroundView.alpha = 1
                self.exampleView.frame = CGRect(
                    x: 0,
                    y: finalY,
                    width: exampleWidth,
                    height: exampleHeight
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
            
            if let window = UIApplication.shared.keyWindow {
                self.exampleView.frame = CGRect(
                    x: 0,
                    y: window.frame.height,
                    width: self.exampleView.frame.width,
                    height: self.exampleView.frame.height
                )
            }
        })
    }
}
