/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import android.graphics.*
import android.graphics.drawable.Drawable
import java.lang.Float.min

class BorderDrawable(val borderWidth: Float, borderColor: Int, val borderRadius: Float): Drawable() {
    private val borderPaint = Paint()

    init {
        borderPaint.style = Paint.Style.STROKE
        borderPaint.strokeWidth = borderWidth
        borderPaint.color = borderColor
    }

    override fun draw(canvas: Canvas) {
        val radius = if (borderRadius == Float.MAX_VALUE) min(bounds.width().toFloat(), bounds.height().toFloat()) / 2f else borderRadius

        canvas.drawRoundRect(
                RectF(
                        bounds.left.toFloat() + borderPaint.strokeWidth / 2,
                        bounds.top.toFloat() + borderPaint.strokeWidth / 2,
                        bounds.right.toFloat() - borderPaint.strokeWidth / 2,
                        bounds.bottom.toFloat() - borderPaint.strokeWidth / 2),
                radius,
                radius,
                borderPaint)
    }

    override fun setAlpha(alpha: Int) {
        borderPaint.alpha = alpha
        invalidateSelf()
    }

    override fun getOpacity(): Int {
        return borderPaint.alpha
    }

    override fun setColorFilter(colorFilter: ColorFilter?) {
        borderPaint.colorFilter = colorFilter
        invalidateSelf()
    }
}