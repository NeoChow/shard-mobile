/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml.viewimpl

import android.content.Context
import android.view.View
import app.visly.vml.*

abstract class BaseViewImpl<T: View>(val ctx: Context): VMLViewImpl<T> {
    internal var backgroundColor = 0
    internal var borderColor = 0
    internal var borderRadius = 0f
    internal var borderWidth = 0f

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