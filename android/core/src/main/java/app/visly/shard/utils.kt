/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard

import android.content.Context
import java.lang.IllegalArgumentException

data class Size(val width: Float, val height: Float)

data class Color(val default: Int, val pressed: Int?)

fun dipsToPixels(ctx: Context, dips: Float): Float {
    val scale = ctx.resources.displayMetrics.density
    return Math.round(dips * scale).toFloat()
}

fun sipsToPixels(ctx: Context, dips: Float): Float {
    val scale = ctx.resources.displayMetrics.scaledDensity
    return Math.round(dips * scale).toFloat()
}

// Patch android Color.parseColor() to handle #F00
fun parseColorString(color: String): Int {
    return android.graphics.Color.parseColor(if(color.length == 4) {
        "#" + color[1] + color[1] + color[2] + color[2] + color[3] + color[3]
    } else color)
}

fun JsonValue.toColor(): Color {
    return when (this) {
        is JsonValue.String -> Color(parseColorString(this.value), null)
        is JsonValue.Object -> {
            val default = (this.value["default"] as JsonValue.String).value
            val pressed = (this.value["pressed"] as JsonValue.String?)?.value
            Color(
                    parseColorString(default),
                    if (pressed == null) null else parseColorString(pressed))
        }
        else -> throw IllegalArgumentException()
    }
}

fun JsonValue.Object.toDips(ctx: Context): Float {
    val value = (this.value["value"] as JsonValue.Number).value
    val unit = this.value["unit"]

    return when (unit) {
        JsonValue.String("points") -> dipsToPixels(ctx, value)
        JsonValue.String("pixels") -> value
        else -> 0f
    }
}

fun JsonValue.Object.toSips(ctx: Context): Float {
    val value = (this.value["value"] as JsonValue.Number).value
    val unit = this.value["unit"]

    return when (unit) {
        JsonValue.String("points") -> sipsToPixels(ctx, value)
        JsonValue.String("pixels") -> value
        else -> 0f
    }
}

fun String.quote(): String = "\"${this}\""