/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

class VMLSolidColorShadowView : VMLShadowView {
    private lazy var view = VMLBaseView()
    private var baseProps: VMLBaseProps? = nil
    
    override func setProps(_ props: [String: JSON]) throws {
        self.baseProps = try VMLBaseProps(props)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize  {
        return size
    }
    
    override func getView() -> VMLView  {
        self.view.frame = self.frame
        baseProps?.apply(ctx: ctx, view: self.view)
        return view
    }
}
