/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package app.visly

import android.content.ContextWrapper
import android.view.View
import app.visly.shadowview.ShadowView
import app.visly.shadowview.ShadowViewParent

class VMLContext(val root: VMLRootView, val config: VMLConfig) : ContextWrapper(root.context) {

    fun createShadowView(kind: String, parent: ShadowViewParent?): ShadowView {
        val constructor = config.shadowViewsConstructors[kind]

        if (constructor != null) {
            return constructor(this, parent)
        } else {
            throw IllegalArgumentException("Unknown kind: $kind")
        }
    }

    fun dispatchEvent(type: String, data: VMLObject) {
        root.dispatchEvent(type, data)
    }
}