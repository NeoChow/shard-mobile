/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit
import Kingfisher

internal class ImageViewImpl: BaseViewImpl {
    internal var imgSize: CGSize = .zero
    internal var src: URL? = nil
    internal var contentMode: UIView.ContentMode = .center
    
    override func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        return CGSize(width: width ?? imgSize.width, height: height ?? imgSize.height)
    }
    
    override func setProp(key: String, value: JsonValue) {
        super.setProp(key: key, value: value)
        
        switch key {
        case "src":
            self.src = URL(string: try! value.asString())
        case "content-mode":
            switch value {
            case .String(let value) where value == "cover": self.contentMode = .scaleAspectFill
            case .String(let value) where value == "contain": self.contentMode = .scaleAspectFit
            case .String(let value) where value == "center": self.contentMode = .center
            default: self.contentMode = .center
            }
        default: ()
        }
    }
    
    override func createView() -> UIView {
        let image = UIImageView()
        image.layer.masksToBounds = true
        
        let scale = UIScreen.main.scale
        image.transform = CGAffineTransform.init(scaleX: 1 / scale, y: 1 / scale)
        
        return image
    }
    
    override func bindView(_ view: UIView) {
        super.bindView(view)
        
        let view = view as! UIImageView
        view.contentMode = contentMode
        view.kf.setImage(with: src!) { result in
            if let image = result.value?.image {
                self.imgSize = image.size
                // TODO re-layout
            }
        }
    }
}
