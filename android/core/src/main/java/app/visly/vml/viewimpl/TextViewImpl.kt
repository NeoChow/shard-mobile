/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml.viewimpl

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.text.Spannable
import android.text.SpannableString
import android.text.SpannableStringBuilder
import android.text.Spanned
import android.util.TypedValue
import android.widget.TextView
import app.visly.vml.*
import com.facebook.fbui.textlayoutbuilder.TextLayoutBuilder
import com.facebook.fbui.textlayoutbuilder.util.LayoutMeasureUtil

class TextViewImpl(ctx: Context): BaseViewImpl<TextView>(ctx) {
    internal var textAlign: Int = TextView.TEXT_ALIGNMENT_TEXT_START
    internal var maxLines: Int = Integer.MAX_VALUE
    internal var spacingMultiplier: Float = 1.0f
    internal var textSpan: Spannable = SpannableString("")

    override fun measure(width: Float?, height: Float?): Size {
        val textMeasureMode = when (width) {
            null -> TextLayoutBuilder.MEASURE_MODE_UNSPECIFIED
            else -> TextLayoutBuilder.MEASURE_MODE_EXACTLY
        }

        val textLayout = TextLayoutBuilder()
                .setText(textSpan)
                .setTextSize(Math.round(ctx.resources.displayMetrics.scaledDensity * 12f))
                .setWidth(width?.toInt() ?: Int.MAX_VALUE, textMeasureMode)
                .setIncludeFontPadding(true)
                .build()

        return if (textLayout != null) {
            Size(
                    width ?: textLayout.width.toFloat(),
                    height ?: LayoutMeasureUtil.getHeight(textLayout).toFloat())
        } else {
            Size(width ?: 0f, height ?: 0f)
        }
    }

    override fun setProp(key: String, value: JsonValue) {
        super.setProp(key, value)

        when (key) {
            "text-align" -> {
                textAlign = when (value) {
                    JsonValue.String("start") -> TextView.TEXT_ALIGNMENT_TEXT_START
                    JsonValue.String("end") -> TextView.TEXT_ALIGNMENT_TEXT_END
                    JsonValue.String("center") -> TextView.TEXT_ALIGNMENT_CENTER
                    else -> TextView.TEXT_ALIGNMENT_TEXT_START
                }
            }

            "max-lines" -> {
                maxLines = when (value) {
                    is JsonValue.Number -> value.value.toInt()
                    else -> Integer.MAX_VALUE
                }
            }

            "line-height" -> {
                spacingMultiplier = when (value) {
                    is JsonValue.Object -> (value.value["value"] as JsonValue.Number).value
                    else -> 1f
                }
            }

            "span" -> {
                textSpan = when (value) {
                    is JsonValue.Object -> makeSpan(value.value)
                    else -> SpannableString("")
                }
            }
        }
    }

    fun makeSpan(props: Map<String, JsonValue>): Spannable {
        val span = SpannableStringBuilder()

        when (val value = props["text"]) {
            is JsonValue.String -> { span.append(value.value) }
            is JsonValue.Array -> {
                for (i in 0 until value.value.size) {
                    when (val child = value.value.get(i)) {
                        is JsonValue.Object -> span.append(makeSpan(child.value))
                    }
                }
            }
        }

        val fontColor = when (val value = props["font-color"]) {
            is JsonValue.String -> parseColor(value.value)
            else -> null
        }

        val fontFamily = when (val value = props["font-family"]) {
            is JsonValue.String -> value.value
            else -> null
        }

        val fontStyle = when (val value = props["font-style"]) {
            JsonValue.String("normal") -> Typeface.NORMAL
            JsonValue.String("italic") -> Typeface.ITALIC
            else -> null
        }

        val fontWeight = when (val value = props["font-weight"]) {
            JsonValue.String("regular") -> Typeface.NORMAL
            JsonValue.String("bold") -> Typeface.BOLD
            else -> null
        }

        val fontSize = when (val value = props["font-size"]) {
            is JsonValue.Object -> value.toSips(ctx)
            else -> null
        }

        val start = 0
        val end = span.length

        span.setSpan(
                VMLTextSpan(fontStyle, fontWeight, fontSize, fontColor, fontFamily, ctx),
                start,
                end,
                Spanned.SPAN_INCLUSIVE_EXCLUSIVE)

        return span
    }

    override fun createView(): TextView {
        return TextView(ctx)
    }

    override fun bindView(view: TextView) {
        super.bindView(view)
        view.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
        view.setTextColor(Color.BLACK)
        view.setLineSpacing(0f, spacingMultiplier)
        view.maxLines = maxLines
        view.textAlignment = textAlign
        view.text = textSpan
    }
}