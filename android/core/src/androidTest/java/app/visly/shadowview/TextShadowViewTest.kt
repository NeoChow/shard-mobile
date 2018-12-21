/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.app.Application
import android.widget.TextView
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.visly.*
import junit.framework.Assert.assertEquals
import org.junit.Test
import org.junit.Before
import org.junit.runner.RunWith
import java.lang.IllegalArgumentException

@RunWith(AndroidJUnit4::class)
class TextShadowViewTest {

    private lateinit var context: VMLContext

    @Before
    fun setup() {
        val appContext = InstrumentationRegistry.getInstrumentation().context.applicationContext
        VML.init(appContext as Application)
        val root = VMLRootView(appContext)
        context = VMLContext(root, VMLConfig.default)
    }

    @Test
    fun testProps() {
        val shadow = TextShadowView(context, null)
        shadow.setProps(VMLObject(mapOf(
                "text" to "Hello",
                "font-size" to VMLObject(mapOf(
                        "unit" to "point",
                        "value" to 10
                )),
                "font-color" to VMLObject(mapOf(
                        "default" to "#F00"
                )),
                "text-align" to "start",
                "max-lines" to 10,
                "line-height" to VMLObject(mapOf(
                        "unit" to "percent",
                        "value" to 200
                ))
        )))

        val view = shadow.getView() as TextView
        assertEquals(view.text.toString(), "Hello")
        assertEquals(view.textAlignment, TextView.TEXT_ALIGNMENT_TEXT_START)
        assertEquals(view.maxLines, 10)
        assertEquals(view.lineSpacingExtra, 0f)
        assertEquals(view.lineSpacingMultiplier, 2f)
    }

    @Test(expected = IllegalArgumentException::class)
    fun testTextRequired() {
        val shadow = TextShadowView(context, null)
        shadow.setProps(VMLObject(mapOf()))
    }

    @Test
    fun testDefaults() {
        val shadow = TextShadowView(context, null)
        shadow.setProps(VMLObject(mapOf(
                "text" to "Hello"
        )))

        val view = shadow.getView() as TextView
        assertEquals(view.textAlignment, TextView.TEXT_ALIGNMENT_TEXT_START)
        assertEquals(view.maxLines, Int.MAX_VALUE)
        assertEquals(view.lineSpacingExtra, 0f)
        assertEquals(view.lineSpacingMultiplier, 1f)
    }
}
