package app.visly

import android.graphics.*
import android.graphics.drawable.Drawable
import java.lang.Float.min

class BorderDrawable: Drawable() {
    private val borderPaint = Paint()
    private var borderRadius = 0f

    init {
        borderPaint.style = Paint.Style.STROKE
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

    fun setBorderWidth(borderWidth: Float) {
        borderPaint.strokeWidth = borderWidth
        invalidateSelf()
    }

    fun setBorderColor(borderColor: Int) {
        borderPaint.color = borderColor
        invalidateSelf()
    }

    fun setBorderRadius(borderRadius: Float) {
        this.borderRadius = borderRadius
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