/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package app.visly

import android.content.res.Resources
import android.graphics.Color

data class Size(val width: Int, val height: Int)

fun dipsToPixels(res: Resources, dips: Float): Int {
    val scale = res.displayMetrics.density
    return Math.round(dips * scale)
}

fun sipsToPixels(res: Resources, dips: Float): Int {
    val scale = res.displayMetrics.scaledDensity
    return Math.round(dips * scale)
}

// Patch android Color.parseColor() to handle #F00
fun parseColor(color: String): Int {
    return Color.parseColor(if(color.length == 4) {
        "#" + color[1] + color[1] + color[2] + color[2] + color[3] + color[3]
    } else color)
}
