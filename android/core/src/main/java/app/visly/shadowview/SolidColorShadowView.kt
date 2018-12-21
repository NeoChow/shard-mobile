/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.view.View
import app.visly.Size
import app.visly.VMLContext
import app.visly.VMLObject

class SolidColorShadowView(ctx: VMLContext, parent: ShadowViewParent?): ShadowView(ctx, parent) {
    private val color: View by lazy { View(ctx) }
    private var baseProps: BaseShadowViewProps? = null

    override fun setProps(props: VMLObject) {
        baseProps = BaseShadowViewProps(ctx, props)
    }

    override fun measure(widthMeasureSpec: Int, heightMeasureSpec: Int): Size {
        val width = Math.max(0, View.MeasureSpec.getSize(widthMeasureSpec))
        val height = Math.max(0, View.MeasureSpec.getSize(heightMeasureSpec))
        return Size(width, height)
    }

    override fun getView(): View {
        baseProps?.applyTo(color)
        return color
    }
}