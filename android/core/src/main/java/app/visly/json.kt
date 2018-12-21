/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package app.visly

import android.content.res.ColorStateList
import android.content.res.Resources
import org.json.JSONArray
import org.json.JSONObject
import com.facebook.yoga.YogaValue
import com.facebook.yoga.YogaUnit

class VMLObject internal constructor(private val json: JSONObject) {

    companion object {
        private fun toJson(data: Map<String, Any>): JSONObject {
            val json = JSONObject()
            for ((key, value) in data) {
                json.put(key, value)
            }
            return json
        }
    }

    constructor(): this(JSONObject())
    constructor(data: Map<String, Any>): this(toJson(data))

    fun <T> get(key: String, body: (Any?) -> T): T {
        var value = json.opt(key)
        value = when (value) {
            is JSONObject -> VMLObject(value)
            is JSONArray -> VMLArray(value)
            else -> value
        }
        return body(value)
    }
}

class VMLArray internal constructor(private val json: JSONArray) {

    companion object {
        private fun toJson(data: Array<out Any>): JSONArray {
            val json = JSONArray()
            for (value in data) {
                json.put(value)
            }
            return json
        }
    }

    constructor(): this(JSONArray())
    constructor(data: Array<out Any>): this(toJson(data))

    fun <T> get(index: Int, body: (Any?) -> T): T {
        var value = json.opt(index)
        value = when (value) {
            is JSONObject -> VMLObject(value)
            is JSONArray -> VMLArray(value)
            else -> value
        }
        return body(value)
    }

    fun length() = json.length()
}

internal fun VMLObject.toYogaValue(res: Resources): YogaValue {
    return get("value") { value ->
        when (value) {
            is Number -> {
                get("unit") {
                    when (it) {
                        "pixel" -> YogaValue(value.toFloat(), YogaUnit.POINT)
                        "point" -> YogaValue(dipsToPixels(res, value.toFloat()).toFloat(), YogaUnit.POINT)
                        "percent" -> YogaValue(value.toFloat(), YogaUnit.PERCENT)
                        else -> throw IllegalArgumentException("Unexpected unit: $it")
                    }
                }
            }
            else -> throw IllegalArgumentException("Unexpected value: $value")
        }
    }
}

internal fun VMLObject.toPixels(res: Resources): Float {
    return get("value") { value ->
        when (value) {
            is Number -> {
                get("unit") {
                    when (it) {
                        "pixel" -> value.toFloat()
                        "point" -> dipsToPixels(res, value.toFloat()).toFloat()
                        else -> throw IllegalArgumentException("Unexpected unit: $it")
                    }
                }
            }
            else -> throw IllegalArgumentException("Unexpected value: $value")
        }
    }
}

internal fun VMLObject.toColorStateList(): ColorStateList {
    val default = get("default") {
        when (it) {
            is String -> it
            else -> throw IllegalArgumentException("Unexpected color value: $it")
        }
    }

    val pressed = get("pressed") {
        when (it) {
            is String -> it
            null -> null
            else -> throw IllegalArgumentException("Unexpected color value: $it")
        }
    }

    return ColorStateList(
            arrayOf(
                    intArrayOf(android.R.attr.state_pressed),
                    intArrayOf()
            ),
            intArrayOf(
                    parseColor(pressed ?: default),
                    parseColor(default)
            )
    )
}
