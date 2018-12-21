/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly

import org.json.JSONArray
import org.json.JSONObject
import org.junit.Test
import org.junit.Assert.assertTrue
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class JsonTest {

    @Test
    fun testGetJSONObjectOnObject() {
        val vml = VMLObject(mapOf("test" to JSONObject()))
        assertTrue(vml.get("test") { it } is VMLObject)
    }

    @Test
    fun testGetJSONArrayOnObject() {
        val vml = VMLObject(mapOf("test" to JSONArray()))
        assertTrue(vml.get("test") { it } is VMLObject)
    }

    @Test
    fun testGetJSONObjectInArray() {
        val vml = VMLArray(arrayOf(JSONObject()))
        assertTrue(vml.get(0) { it } is VMLObject)
    }

    @Test
    fun testGetJSONArrayInArray() {
        val vml = VMLArray(arrayOf(JSONArray()))
        assertTrue(vml.get(0) { it } is VMLArray)
    }
}
