package app.visly.vml

import android.content.Context
import android.graphics.Color

data class Size(val width: Float, val height: Float)

fun dipsToPixels(ctx: Context, dips: Float): Int {
    val scale = ctx.resources.displayMetrics.density
    return Math.round(dips * scale)
}

fun sipsToPixels(ctx: Context, dips: Float): Int {
    val scale = ctx.resources.displayMetrics.scaledDensity
    return Math.round(dips * scale)
}

// Patch android Color.parseColor() to handle #F00
fun parseColor(color: String): Int {
    return Color.parseColor(if(color.length == 4) {
        "#" + color[1] + color[1] + color[2] + color[2] + color[3] + color[3]
    } else color)
}

fun JsonValue.Object.toPixels(ctx: Context): Int {
    val value = (this.value["value"] as JsonValue.Number).value
    val unit = this.value["unit"]

    return when (unit) {
        JsonValue.String("points") -> dipsToPixels(ctx, value)
        JsonValue.String("pixels") -> value.toInt()
        else -> 0
    }
}