/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly

import android.graphics.Typeface
import android.content.res.AssetManager
import android.graphics.Paint
import android.text.TextPaint
import android.text.style.MetricAffectingSpan


class VMLTextSpan(
        private val style: Int?,
        private val weight: Int?,
        private val size: Float?,
        private val color: Int?,
        private val fontFamily: String?,
        private val assetManager: AssetManager) : MetricAffectingSpan() {


    override fun updateDrawState(paint: TextPaint) {
        apply(paint, style, weight, size, color, fontFamily, assetManager)
    }

    override fun updateMeasureState(paint: TextPaint) {
        apply(paint, style, weight, size, color, fontFamily, assetManager)
    }

    private fun apply(paint: Paint, style: Int?, weight: Int?, size: Float?, color: Int?, family: String?, assetManager: AssetManager) {
        var typeface = paint.getTypeface()
        val oldStyle = typeface?.getStyle() ?: 0

        var want = 0
        if (weight == Typeface.BOLD || oldStyle and Typeface.BOLD != 0 && weight == null) {
            want = want or Typeface.BOLD
        }

        if (style == Typeface.ITALIC || oldStyle and Typeface.ITALIC != 0 && style == null) {
            want = want or Typeface.ITALIC
        }

        typeface = if (family != null) {
            VMLFontManager.instance.getTypeface(family, want, assetManager)
        } else if (typeface != null) {
            Typeface.create(typeface, want)
        } else {
            typeface
        }

        paint.typeface = if (typeface != null) {
            typeface
        } else {
            Typeface.defaultFromStyle(want)
        }

        if (color != null) paint.color = color
        if (size != null) paint.textSize = size

        paint.isSubpixelText = true
    }

}