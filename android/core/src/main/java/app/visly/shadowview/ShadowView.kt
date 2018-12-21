/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.graphics.Rect
import android.view.View
import app.visly.Size
import app.visly.VMLContext
import app.visly.VMLObject

// A shadow view is a long-lived object and may be re-used once a new
// update comes down from the server given that its parent is still the same.
// If a shadow view  is re-used then setProps() will be called again. This can be
// used to re-use any large state, like an Android View, for incremental re-renders.
//
// Shadow views are built to be able to be instantiated on a background
// thread. ** Do not create any UI-bound objects until getView() is called **
abstract class ShadowView(val ctx: VMLContext, val parent: ShadowViewParent?) {

    // The frame of this shadow view. This property can be set off of
    // the UI thread so ** Do set the frame directly on a View **. Wait until
    // getView() to transfer the size and position to the view.
    var frame: Rect = Rect()

    // Transfer the props from the VML response onto the shadow view.
    // This method should not set any properties on an Android View as this
    // method is meant to be able to be called from a background thread.
    // Instead you should validate the json payload and transfer values
    // onto properties of this shadow view to be set on a View once
    // getView() is called.
    //
    // Should throw with error message if any properties weren't specified
    // according to spec.
    abstract fun setProps(props: VMLObject)

    // Like View.onMeasure() but not bound to the UI thread.
    // Return the size of this shadow view within the constraints of the
    // given size. This method can be called off of the UI thread so
    // ** Do not delegate to View.measure() **.
    abstract fun measure(widthMeasureSpec: Int, heightMeasureSpec: Int): Size

    // Create and return an Android View matching the properties and size set with
    // setProps() and setFrame(). This method will always be called from the
    // UI thread. For efficient incremental updates it is suggested that you
    // lazily create the View associated with this shadow view once and then
    // only update its properties on subsequent calls.
    //
    // Container views (implementing VMLShadowViewParent) are responsible for
    // calling getView() on their child shadow views and inserting them into
    // their Views before returning from this method.
    abstract fun getView(): View
}

abstract class ShadowViewParent(ctx: VMLContext, parent: ShadowViewParent?): ShadowView(ctx, parent) {
    // Layout the children of this shadow view according to the frame
    // previously set by setFrame(). It is the responsibility of the
    // shadow view parent to call setFrame() and layoutChildren() on
    // any child shadow views / view parents.
    // ** This method may be called off of the UI thread **
    abstract fun layoutChildren()

    // Inform this parent that a child shadow view requires a re-layout.
    // This method is unually called in response to a callback on a UIView,
    // for example when an image as been loaded from the network or when
    // text has been typed into a UIInput. This method may be called on or
    // off the UI thread.
    abstract fun requestLayout(dirtyChild: ShadowView)
}