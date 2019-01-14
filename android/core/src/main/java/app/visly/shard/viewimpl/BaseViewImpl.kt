/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard.viewimpl

import android.view.View
import app.visly.shard.*

abstract class BaseViewImpl<T: View>(val ctx: ShardContext): ShardViewImpl<T> {
    internal var backgroundColor: Color = Color(0, null)
    internal var borderColor = 0
    internal var borderRadius = 0f
    internal var borderWidth = 0f
    internal var onClick: View.OnClickListener? = null

    override fun setProp(key: String, value: JsonValue) {
        when (key) {
            "background-color" -> {
                backgroundColor = value.toColor()
            }

            "border-color" -> {
                borderColor = value.toColor().default
            }

            "border-radius" -> {
                borderRadius = when (value) {
                    JsonValue.String("max") -> Float.MAX_VALUE
                    is JsonValue.Object -> value.toDips(ctx)
                    else -> 0f
                }
            }

            "border-width" -> {
                borderWidth = when (value) {
                    is JsonValue.Object -> value.toDips(ctx)
                    else -> 0f
                }
            }

            "on-click" -> {
                onClick = when (value) {
                    is JsonValue.Object -> View.OnClickListener {
                        val action = (value.value.get("action") as JsonValue.String).value
                        val value = value.value.get("value")
                        ctx.dispatch(action, value)
                    }
                    else -> null
                }
            }
        }
    }

    override fun bindView(view: T) {
        view.setOnClickListener(this.onClick)
        view.background = BackgroundDrawable(backgroundColor, borderRadius)
        view.foreground = BorderDrawable(borderWidth, borderColor, borderRadius)
    }
}