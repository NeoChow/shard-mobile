/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard

import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.Assert.assertTrue
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class JsonValueTest {

    @Test
    fun testParseNull() {
        val result = JsonValue.parse("null")
        assertTrue(result is JsonValue.Null)
    }

    @Test
    fun testParseBoolean() {
        val result = JsonValue.parse("true")
        assertTrue(result is JsonValue.Boolean)
    }

    @Test
    fun testParseString() {
        val result = JsonValue.parse("\"test\"")
        assertTrue(result is JsonValue.String)
    }

    @Test
    fun testParseInt() {
        val result = JsonValue.parse("1")
        assertTrue(result is JsonValue.Number)
    }

    @Test
    fun testParseFloat() {
        val result = JsonValue.parse("1.0")
        assertTrue(result is JsonValue.Number)
    }

    @Test
    fun testParseObject() {
        val result = JsonValue.parse("{\"key\": \"value\"}")
        assertTrue(result is JsonValue.Object)
        assertEquals((result as JsonValue.Object).value, mapOf("key" to JsonValue.String("value")))
    }

    @Test
    fun testParseArray() {
        val result = JsonValue.parse("[\"value\"]")
        assertTrue(result is JsonValue.Array)
        assertEquals((result as JsonValue.Array).value, listOf(JsonValue.String("value")))
    }

    @Test
    fun testToString() {
        val value = JsonValue.parse("""{
            "one": "1",
            "two": 2,
            "three": true,
            "four": {
                "key": "value"
            },
            "five": ["value"]
        }""")
        assertEquals(value.toString(), """{"one":"1","two":2.0,"three":true,"four":{"key":"value"},"five":["value"]}""")
    }
}
