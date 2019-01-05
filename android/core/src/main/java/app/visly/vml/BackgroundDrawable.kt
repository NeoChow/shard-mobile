package app.visly.vml

import android.graphics.*
import android.graphics.drawable.Drawable
import java.lang.Float.min

class BackgroundDrawable(backgroundColor: Int, val borderRadius: Float): Drawable() {
    private val backgroundPaint = Paint()

    init {
        backgroundPaint.style = Paint.Style.FILL
        backgroundPaint.color = backgroundColor
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