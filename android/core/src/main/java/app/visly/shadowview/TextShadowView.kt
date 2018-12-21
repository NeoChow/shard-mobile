/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.graphics.Color
import android.view.View
import com.facebook.fbui.textlayoutbuilder.TextLayoutBuilder
import com.facebook.fbui.textlayoutbuilder.util.LayoutMeasureUtil
import android.graphics.Typeface
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan
import android.util.TypedValue
import android.view.View.MeasureSpec.AT_MOST
import android.view.View.MeasureSpec.EXACTLY
import android.view.View.MeasureSpec.UNSPECIFIED
import android.widget.TextView
import app.visly.*

class TextShadowView(ctx: VMLContext, parent: ShadowViewParent?): ShadowView(ctx, parent) {
    private var baseProps: BaseShadowViewProps? = null

    private var textAlign: Int = TextView.TEXT_ALIGNMENT_TEXT_START
    private var maxLines: Int = Integer.MAX_VALUE
    private var spacingMultiplier: Float = 1.0f
    private var textSpan: Spannable? = null

    override fun setProps(props: VMLObject) {
        baseProps = BaseShadowViewProps(ctx, props)

        textAlign = props.get("text-align") {
            when (it) {
                null, "start" -> TextView.TEXT_ALIGNMENT_TEXT_START
                "end" ->  TextView.TEXT_ALIGNMENT_TEXT_END
                "center" ->  TextView.TEXT_ALIGNMENT_CENTER
                else -> throw IllegalArgumentException("Unexpected value for text-align: $it")
            }
        }

        maxLines = props.get("max-lines") {
            when (it) {
                is Number -> it.toInt()
                null -> Integer.MAX_VALUE
                else -> throw IllegalArgumentException("Unexpected value for max-lines: $it")
            }
        }

        spacingMultiplier = props.get("line-height") {
            when (it) {
                is VMLObject -> {
                    it.get("unit") {
                        when (it) {
                            "percent" -> {}
                            else -> throw IllegalArgumentException("Unexpected unit: $it")
                        }
                    }

                    it.get("value") {
                        when (it) {
                            is Number -> it.toFloat() / 100f
                            else -> throw IllegalArgumentException("Unexpected value: $it")
                        }
                    }
                }
                null -> 1.0f
                else -> throw IllegalArgumentException("Unexpected value for line-height-multiplier: $it")
            }
        }

        textSpan = makeSpan(props)
    }

    private fun resolveSize(sizeSpec: Int, preferredSize: Int): Int {
        return when (View.MeasureSpec.getMode(sizeSpec)) {
            EXACTLY -> View.MeasureSpec.getSize(sizeSpec)
            AT_MOST -> Math.min(View.MeasureSpec.getSize(sizeSpec), preferredSize)
            UNSPECIFIED -> preferredSize
            else -> throw IllegalStateException("Unexpected size mode: " + View.MeasureSpec.getMode(sizeSpec))
        }
    }

    override fun measure(widthMeasureSpec: Int, heightMeasureSpec: Int): Size {
        val textMeasureMode = when (View.MeasureSpec.getMode(widthMeasureSpec)) {
            View.MeasureSpec.UNSPECIFIED -> TextLayoutBuilder.MEASURE_MODE_UNSPECIFIED
            View.MeasureSpec.AT_MOST -> TextLayoutBuilder.MEASURE_MODE_AT_MOST
            View.MeasureSpec.EXACTLY -> TextLayoutBuilder.MEASURE_MODE_EXACTLY
            else -> throw java.lang.IllegalStateException()
        }

        val textLayout = TextLayoutBuilder()
                .setText(textSpan)
                .setTextSize(Math.round(ctx.resources.displayMetrics.scaledDensity * 12f))
                .setWidth(View.MeasureSpec.getSize(widthMeasureSpec), textMeasureMode)
                .setIncludeFontPadding(true)
                .build()!!

        val width = Math.max(0, resolveSize(widthMeasureSpec, textLayout.width))
        val height = Math.max(0, resolveSize(heightMeasureSpec, LayoutMeasureUtil.getHeight(textLayout)))

        return Size(width, height)
    }

    override fun getView(): View {
        val textview = TextView(ctx)
        baseProps?.applyTo(textview)
        textview.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
        textview.setTextColor(Color.BLACK)
        textview.setLineSpacing(0f, spacingMultiplier)
        textview.maxLines = maxLines
        textview.textAlignment = textAlign
        textview.text = textSpan
        return textview
    }

    fun makeSpan(props: VMLObject): Spannable {
        val span = SpannableStringBuilder()

        props.get("text") {
            when (it) {
                is String -> span.append(it)
                is VMLArray -> {
                    for (i in 0 until it.length()) {
                        it.get(i) {
                            when (it) {
                                is VMLObject -> span.append(makeSpan(it))
                                else -> throw IllegalArgumentException("Unexpected value: $it")
                            }
                        }
                    }
                }
                else -> throw IllegalArgumentException("Unexpected value for text: $it")
            }
        }

        val fontColor = props.get("font-color") {
            when (it) {
                is VMLObject -> it.toColorStateList().defaultColor
                null -> null
                else -> throw IllegalArgumentException("Unexpected value for font-color: $it")
            }
        }

        val fontFamily: String? = props.get("font-family") {
            when (it) {
                is String -> it
                null -> null
                else -> throw IllegalArgumentException("Unexpected value for font-family: $it")
            }
        }

        val fontStyle: Int? = props.get("font-style") {
            when (it) {
                "normal" -> Typeface.NORMAL
                "italic" -> Typeface.ITALIC
                null -> null
                else -> throw IllegalArgumentException("Unexpected value for font-style: $it")
            }
        }

        val fontWeight: Int? = props.get("font-weight") {
            when (it) {
                "regular" -> Typeface.NORMAL
                "bold" -> Typeface.BOLD
                null -> null
                else -> throw IllegalArgumentException("Unexpected value for font-weight: $it")
            }
        }

        val fontSize = props.get("font-size") {
            when (it) {
                is VMLObject -> {
                    val value = it.get("value") {
                        when (it) {
                            is Number -> it.toFloat()
                            else -> throw IllegalArgumentException("Unexpected value: $it")
                        }
                    }

                    it.get("unit") {
                        when (it) {
                            "pixel" -> value
                            "point" -> value * ctx.resources.displayMetrics.scaledDensity
                            else -> throw IllegalArgumentException("Unexpected unit: $it")
                        }
                    }
                }
                null -> null
                else -> throw IllegalArgumentException("Unexpected value for font-size: $it")
            }
        }

        val start = 0
        val end = span.length

        span.setSpan(
                VMLTextSpan(fontStyle, fontWeight, fontSize, fontColor, fontFamily, ctx.resources.assets),
                start,
                end,
                Spanned.SPAN_INCLUSIVE_EXCLUSIVE)

        return span
    }
}