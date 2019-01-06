/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml.viewimpl

import android.widget.TextView
import androidx.test.core.app.ApplicationProvider
import app.visly.vml.JsonValue
import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class TextViewImplTest {

    @Test
    fun testSetTextAlignStart() {
        val viewImpl = TextViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("text-align", JsonValue.String("start"))
        assertEquals(viewImpl.textAlign, TextView.TEXT_ALIGNMENT_TEXT_START)
    }

    @Test
    fun testSetTextAlignEnd() {
        val viewImpl = TextViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("text-align", JsonValue.String("end"))
        assertEquals(viewImpl.textAlign, TextView.TEXT_ALIGNMENT_TEXT_END)
    }

    @Test
    fun testSetTextAlignCenter() {
        val viewImpl = TextViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("text-align", JsonValue.String("center"))
        assertEquals(viewImpl.textAlign, TextView.TEXT_ALIGNMENT_CENTER)
    }

    @Test
    fun testSetMaxLines() {
        val viewImpl = TextViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("max-lines", JsonValue.Number(1f))
        assertEquals(viewImpl.maxLines, 1)
    }

    @Test
    fun testSetLinesHeight() {
        val viewImpl = TextViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("line-height", JsonValue.Object(mapOf(
                "unit" to JsonValue.String("percent"),
                "value" to JsonValue.Number(2f)
        )))
        assertEquals(viewImpl.spacingMultiplier, 2f)
    }

    @Test
    fun testSetSpanSimple() {
        val viewImpl = TextViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("span", JsonValue.Object(mapOf(
                "text" to JsonValue.String("hello")
        )))
        assertEquals(viewImpl.textSpan.toString(), "hello")
    }

    @Test
    fun testSetSpanComplex() {
        val viewImpl = TextViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("span", JsonValue.Object(mapOf(
                "text" to JsonValue.Array(listOf(
                        JsonValue.Object(mapOf(
                                "text" to JsonValue.String("hello")
                        )),
                        JsonValue.Object(mapOf(
                                "text" to JsonValue.String(" ")
                        )),
                        JsonValue.Object(mapOf(
                                "text" to JsonValue.String("world")
                        ))

                ))
        )))
        assertEquals(viewImpl.textSpan.toString(), "hello world")
    }
}
