/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import android.graphics.*
import android.graphics.drawable.Drawable
import kotlin.math.min

class BackgroundDrawable(private val backgroundColor: Color, private val borderRadius: Float): Drawable() {
    private val backgroundPaint = Paint()

    init {
        backgroundPaint.style = Paint.Style.FILL
        backgroundPaint.color = backgroundColor.default
    }

    override fun isStateful(): Boolean {
        return backgroundColor.pressed != null
    }

    override fun setState(stateSet: IntArray): Boolean {
        backgroundPaint.color = if (stateSet.contains(android.R.attr.state_pressed)) {
            backgroundColor.pressed ?: backgroundColor.default
        } else {
            backgroundColor.default
        }

        invalidateSelf()
        return true
    }

    override fun draw(canvas: Canvas) {
        val radius = if (borderRadius == Float.MAX_VALUE) min(bounds.width().toFloat(), bounds.height().toFloat()) / 2f else borderRadius

        canvas.drawRoundRect(
                RectF(bounds),
                radius,
                radius,
                backgroundPaint)
    }

    override fun setAlpha(alpha: Int) {
        backgroundPaint.alpha = alpha
        invalidateSelf()
    }

    override fun getOpacity(): Int {
        return backgroundPaint.alpha
    }

    override fun setColorFilter(colorFilter: ColorFilter?) {
        backgroundPaint.colorFilter = colorFilter
        invalidateSelf()
    }
}