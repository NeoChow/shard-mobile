/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import Kingfisher

class VMLImageShadowView : VMLShadowView {
    private var baseProps: VMLBaseProps? = nil
    private var imgSize: CGSize = .zero

    private lazy var view: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        
        let scale = UIScreen.main.scale
        image.transform = CGAffineTransform.init(scaleX: 1 / scale, y: 1 / scale)
        
        return image
    }()

    private var src: URL? = nil
    private var contentMode: UIView.ContentMode = .center
    
    override func setProps(_ props: [String: JSON]) throws {
        self.baseProps = try VMLBaseProps(props)
        
        self.src = try props.get("src") {
            switch $0 {
            case .String(let value): return URL(string: value)
            case let value: throw "Unexpected value for src: \(value)"
            }
        }
        
        self.contentMode = try props.get("content-mode") {
            switch $0 {
            case .String(let value) where value == "cover": return .scaleAspectFill
            case .String(let value) where value == "contain": return .scaleAspectFit
            case .String(let value) where value == "center": return .center
            case .Null: return .center
            case let value: throw "Unexpected value for content-mode: \(value)"
            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize  {
        return CGSize(
            width: min(imgSize.width, size.width),
            height: min(imgSize.height, size.height))
    }
    
    override func getView() -> VMLView  {
        self.view.frame = self.frame
        self.view.contentMode = contentMode
        self.view.kf.setImage(with: src!, completionHandler: { (image, error, cacheType, imageUrl) in
            if let image = image {
                self.imgSize = image.size
                self.parent?.setNeedsLayout(self)
            }
        })
        
        let wrapper = VMLViewWrapper(wrapping: self.view)
        wrapper.frame = frame
        baseProps?.apply(ctx: ctx, view: wrapper)
        return wrapper
    }
}
