package app.visly.shadowview

import android.graphics.Color
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.view.View
import app.visly.*

class BaseShadowViewProps(val ctx: VMLContext, val props: VMLObject) {
    private val borderRadius: Float = props.get("border-radius") {
        when (it) {
            is VMLObject -> it.toPixels(ctx.resources)
            "max" -> Float.MAX_VALUE
            null -> 0f
            else -> throw IllegalArgumentException("Unexpected value for border-radius: $it")
        }
    }

    private val borderWidth: Float = props.get("border-width") {
        when (it) {
            is VMLObject -> it.toPixels(ctx.resources)
            null -> 0f
            else -> throw IllegalArgumentException("Unexpected value for border-width: $it")
        }
    }

    private val borderColor: Int = props.get("border-color") {
        when (it) {
            is VMLObject -> it.toColorStateList().defaultColor
            null -> Color.TRANSPARENT
            else -> throw IllegalArgumentException("Unexpected value for border-color: $it")
        }
    }

    private val tapAction: ((View) -> Unit)? = props.get("tap-action") { action ->
        when (action) {
            is String -> ({
                ctx.dispatchEvent("perform-action", VMLObject(mapOf("action" to action)))
            })
            null -> null
            else -> throw IllegalArgumentException("Unexpected value for tap-action: $action")
        }
    }

    private val background: Drawable? = props.get("background-color") {
        when (it) {
            is VMLObject -> {
                val background = StateListDrawable()
                it.get("pressed") { color ->
                    when (color) {
                        is String -> {
                            val state = GradientDrawable()
                            state.cornerRadius = borderRadius
                            state.setColor(parseColor(color))
                            background.addState(intArrayOf(android.R.attr.state_pressed), state)
                        }
                        null -> {}
                        else -> throw IllegalArgumentException("Unexpected color value: $it")
                    }
                }


                it.get("default") { color ->
                    when (color) {
                        is String -> {
                            val state = GradientDrawable()
                            state.cornerRadius = borderRadius
                            state.setColor(parseColor(color))
                            background.addState(intArrayOf(), state)
                        }
                        else -> throw IllegalArgumentException("Unexpected color value: $it")
                    }
                }
                background
            }
            null -> null
            else -> throw IllegalArgumentException("Unexpected value for background-color: $it")
        }
    }

    fun applyTo(view: View) {
        if (background != null) {
            view.background = background
        }

        if (tapAction != null) {
            view.setOnClickListener(tapAction)
        }

        if (borderColor != Color.TRANSPARENT && borderWidth > 0f) {
            val border = BorderDrawable()
            border.setBorderColor(borderColor)
            border.setBorderWidth(borderWidth)
            border.setBorderRadius(borderRadius)
            view.foreground = border
        }
    }
}