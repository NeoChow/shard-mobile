package app.visly.vml.viewimpl

import android.content.Context
import android.view.View
import app.visly.vml.*

abstract class BaseViewImpl<T: View>(val ctx: Context): VMLViewImpl<T> {
    private var backgroundColor = 0
    private var borderColor = 0
    private var borderRadius = 0f
    private var borderWidth = 0f

    override fun setProp(key: String, value: JsonValue) {
        when (key) {
            "background-color" -> {
                backgroundColor = when (value) {
                    is JsonValue.String -> parseColor(value.value)
                    else -> 0
                }
            }

            "border-color" -> {
                borderColor = when (value) {
                    is JsonValue.String -> parseColor(value.value)
                    else -> 0
                }
            }

            "border-radius" -> {
                borderRadius = when (value) {
                    JsonValue.String("max") -> Float.MAX_VALUE
                    is JsonValue.Object -> value.toDips(ctx).toFloat()
                    else -> 0f
                }
            }

            "border-width" -> {
                borderWidth = when (value) {
                    is JsonValue.Object -> value.toDips(ctx).toFloat()
                    else -> 0f
                }
            }
        }
    }

    override fun bindView(view: T) {
        view.background = BackgroundDrawable(backgroundColor, borderRadius)
        view.foreground = BorderDrawable(borderWidth, borderColor, borderRadius)
    }
}