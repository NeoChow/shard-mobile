/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import android.content.Context
import android.util.AttributeSet
import android.widget.FrameLayout

class AbsoluteLayout(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) : FrameLayout(context, attrs, defStyleAttr) {
    class LayoutParams(width: Int, height: Int, val x: Int, val y: Int) : FrameLayout.LayoutParams(width, height)

    var size = Size(0f, 0f)

    override fun generateDefaultLayoutParams(): FrameLayout.LayoutParams {
        return LayoutParams(0, 0, 0, 0)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        setMeasuredDimension(size.width.toInt(), size.height.toInt())
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)

        for (i in 0 until childCount) {
            val child = getChildAt(i)
            val params = child.layoutParams as LayoutParams
            child.layout(params.x, params.y, params.x + params.width, params.y + params.height)
        }
    }
}