/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class UtilsTest {

    @Test
    fun testParseSimpleColor() {
        assertEquals(JsonValue.String("#F00").toColor(), Color(android.graphics.Color.RED, null))
        assertEquals(JsonValue.String("#FF0000").toColor(), Color(android.graphics.Color.RED, null))
        assertEquals(JsonValue.String("#FFFF0000").toColor(), Color(android.graphics.Color.RED, null))
    }

    @Test
    fun testParseComplexColor() {
        assertEquals(JsonValue.Object(mapOf("default" to JsonValue.String("#F00"))).toColor(), Color(android.graphics.Color.RED, null))
        assertEquals(JsonValue.Object(mapOf(
                "default" to JsonValue.String("#F00"),
                "pressed" to JsonValue.String("#00F")
        )).toColor(), Color(android.graphics.Color.RED, android.graphics.Color.BLUE))
    }
}
