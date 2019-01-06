/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

internal class SolidColorViewImpl: BaseViewImpl {
    override func measure(width: CGFloat?, height: CGFloat?) -> CGSize {
        return CGSize(width: width ?? 0, height: height ?? 0)
    }
    
    override func setProp(key: String, value: JsonValue) {
        super.setProp(key: key, value: value)
    }
    
    override func createView() -> UIView {
        return UIView()
    }
    
    override func bindView(_ view: UIView) {
        super.bindView(view)
    }
}
