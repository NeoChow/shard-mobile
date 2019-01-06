/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import org.json.JSONArray
import org.json.JSONObject
import org.json.JSONTokener
import java.lang.StringBuilder

private fun JSONArray.toList(): List<JsonValue> {
    val list: MutableList<JsonValue> = mutableListOf()
    for (i in 0 until length()) {
        list.add(JsonValue.from(get(i)))
    }
    return list
}

private fun JSONObject.toMap(): Map<String, JsonValue> {
    val map: MutableMap<String, JsonValue> = mutableMapOf()
    for (key in keys()) {
        map[key] = JsonValue.from(get(key))
    }
    return map
}

sealed class JsonValue {
    object Null : JsonValue() {
        override fun toString(): kotlin.String = JsonValue.toJsonString(this)
    }

    data class String(val value: kotlin.String) : JsonValue()  {
        override fun toString(): kotlin.String = JsonValue.toJsonString(this)
    }

    data class Boolean(val value: kotlin.Boolean) : JsonValue() {
        override fun toString(): kotlin.String = JsonValue.toJsonString(this)
    }

    data class Number(val value: Float) : JsonValue() {
        override fun toString(): kotlin.String = JsonValue.toJsonString(this)
    }

    data class Object(val value: Map<kotlin.String, JsonValue>) : JsonValue() {
        override fun toString(): kotlin.String = JsonValue.toJsonString(this)
    }

    data class Array(val value: List<JsonValue>) : JsonValue() {
        override fun toString(): kotlin.String = JsonValue.toJsonString(this)
    }

    companion object {
        @JvmStatic fun parse(json: kotlin.String): JsonValue {
            return from(JSONTokener(json).nextValue())
        }

        @JvmStatic fun from(value: Any?): JsonValue {
            return when (value) {
                is kotlin.String -> String(value)
                is kotlin.Boolean -> Boolean(value)
                is kotlin.Number -> Number(value.toFloat())
                is JSONObject -> Object(value.toMap())
                is JSONArray -> Array(value.toList())
                else -> Null
            }
        }

        fun toJsonString(value: JsonValue): kotlin.String {
            return when (value) {
                is Null -> "null"
                is String -> value.value.quote()
                is Boolean -> value.value.toString()
                is Number -> value.value.toString()
                is Object -> {
                    val s = StringBuilder()
                    s.append("{")
                    var i = 0
                    for (key in value.value.keys) {
                        s.append(key.quote())
                        s.append(":")
                        s.append(value.value[key])
                        if (i < value.value.size - 1) s.append(","); i++
                    }
                    s.append("}")
                    s.toString()
                }
                is Array -> {
                    val s = StringBuilder()
                    s.append("[")
                    for (i in 0 until value.value.size) {
                        s.append(value.value[i])
                        if (i < value.value.size - 1) s.append(",")
                    }
                    s.append("]")
                    s.toString()
                }
            }
        }
    }
}