package app.visly.vml

import org.json.JSONArray
import org.json.JSONObject
import org.json.JSONTokener

private fun JSONArray.toList(): List<JsonValue> {
    val list: MutableList<JsonValue> = mutableListOf()
    for (i in 0..length()) {
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
    object Null : JsonValue()
    data class String(val value: kotlin.String) : JsonValue()
    data class Number(val value: Float) : JsonValue()
    data class Object(val value: Map<kotlin.String, JsonValue>) : JsonValue()
    data class Array(val value: List<JsonValue>) : JsonValue()

    companion object {
        @JvmStatic fun parse(json: kotlin.String): JsonValue {
            return from(JSONTokener(json).nextValue())
        }

        @JvmStatic fun from(value: Any?): JsonValue {
            return when (value) {
                is kotlin.String -> String(value)
                is kotlin.Number -> Number(value.toFloat())
                is JSONObject -> Object(value.toMap())
                is JSONArray -> Array(value.toList())
                else -> Null
            }
        }
    }
}