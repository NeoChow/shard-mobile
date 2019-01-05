package app.visly.vml

import android.content.Context
import android.graphics.Color

data class Size(val width: Float, val height: Float)

fun dipsToPixels(ctx: Context, dips: Float): Float {
    val scale = ctx.resources.displayMetrics.density
    return Math.round(dips * scale).toFloat()
}

fun sipsToPixels(ctx: Context, dips: Float): Float {
    val scale = ctx.resources.displayMetrics.scaledDensity
    return Math.round(dips * scale).toFloat()
}

// Patch android Color.parseColor() to handle #F00
fun parseColor(color: String): Int {
    return Color.parseColor(if(color.length == 4) {
        "#" + color[1] + color[1] + color[2] + color[2] + color[3] + color[3]
    } else color)
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