/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import UIKit

public class VMLShadowView {
    let ctx: VMLContext
    let parent: VMLShadowViewParent?
    private(set) var frame: CGRect = .zero
    
    // Instantiate a new shadow view. A shadow view is long-lived
    // and may be re-used once a new update comes down from the
    // server given that its parent is still the same. If a shadow view
    // is re-used then setProps() will be called again. This can be
    // used to re-use any large state, like a UIView, for incremental re-renders.
    //
    // Shadow views are built to be able to be instantiated on a background
    // thread. ** Do not create any UI-bound objects until getView() is called **
    init(_ ctx: VMLContext, _ parent: VMLShadowViewParent?) {
        self.ctx = ctx
        self.parent = parent
    }

    // Transfer the props from the VML response onto the shadow view.
    // This method should not set any properties on a UIView as this
    // method is meant to be able to be called from a background thread.
    // Instead you should validate the json payload and transfer values
    // onto properties of this shadow view to be set on a UIView once
    // getView() is called.
    //
    // Should throw with error message if any properties weren't specified
    // according to spec.
    func setProps(_ props: [String: JSON]) throws { fatalError() }
    
    // Like UIView.sizeThatFits(CGSize) but not bound to the UI thread.
    // Return the size of this shadow view within the constraints of the
    // given size. This method can be called off of the UI thread so
    // ** Do not delegate to UIView.sizeThatFits() **.
    func sizeThatFits(_ size: CGSize) -> CGSize { fatalError() }
    
    // Set the frame of this shadow view. This should be a simple property
    // setter for most implementations. This method can be called off of
    // the UI thread so ** Do set the frame directly on a UIView **.
    func setFrame(_ frame: CGRect) {
        self.frame = frame
    }
    
    // Create and return a UIView matching the properties and size set with
    // setProps() and setFrame(). This method will always be called from the
    // UI thread. For efficient incremental updates it is suggested that you
    // lazily create the UIView associated with this shadow view once and then
    // only update its properties on subsequent calls.
    //
    // Container views (implementing VMLShadowViewParent) are responsible for
    // calling getView() on their child shadow views and inserting them into
    // their UIView before returning from this method.
    func getView() -> VMLView { fatalError() }
}

public class VMLShadowViewParent: VMLShadowView {
    // Layout the children of this shadow view according to the frame
    // previously set by setFrame(). It is the responsibility of the
    // shadow view parent to call setFrame() and layoutChildren() on
    // any child shadow views / view parents.
    // ** This method may be called off of the UI thread **
    func layoutChildren() { fatalError() }
    
    // Inform this parent that a child shadow view requires a re-layout.
    // This method is unually called in response to a callback on a UIView,
    // for example when an image as been loaded from the network or when
    // text has been typed into a UIInput. This method may be called on or
    // off the UI thread.
    func setNeedsLayout(_ dirtyChild: VMLShadowView) { fatalError() }
}
