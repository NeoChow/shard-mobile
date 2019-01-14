/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard

import android.annotation.TargetApi
import android.content.Context
import android.os.Build
import android.util.AttributeSet
import android.view.ViewGroup
import android.widget.FrameLayout

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
open class AbsoluteLayout @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0, defStyleRes: Int = 0) : ViewGroup(context, attrs, defStyleAttr, defStyleRes) {
    class LayoutParams(width: Int, height: Int, val x: Int, val y: Int) : FrameLayout.LayoutParams(width, height)

    var size = Size(0f, 0f)

    override fun generateDefaultLayoutParams(): FrameLayout.LayoutParams {
        return LayoutParams(0, 0, 0, 0)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        setMeasuredDimension(size.width.toInt(), size.height.toInt())

        for (i in 0 until childCount) {
            val child = getChildAt(i)
            val params = child.layoutParams as LayoutParams
            measureChildren(MeasureSpec.makeMeasureSpec(params.width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(params.height, MeasureSpec.EXACTLY))
        }
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        for (i in 0 until childCount) {
            val child = getChildAt(i)
            val params = child.layoutParams as LayoutParams
            child.layout(params.x, params.y, params.x + params.width, params.y + params.height)
        }
    }
}