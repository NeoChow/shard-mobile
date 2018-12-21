/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.app.Application
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.visly.*
import com.facebook.yoga.*
import junit.framework.Assert.assertEquals
import org.junit.Test
import org.junit.Before
import org.junit.runner.RunWith
import java.lang.IllegalArgumentException

@RunWith(AndroidJUnit4::class)
class YogaShadowViewTest {

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
        val shadow = YogaShadowView(context, null)
        shadow.setProps(VMLObject(mapOf(
                "flex-direction" to "row",
                "flex-wrap" to "wrap",
                "align-items" to "center",
                "align-content" to "center",
                "justify-content" to "center",
                "padding" to VMLObject(mapOf(
                        "unit" to "point",
                        "value" to 100
                )),
                "padding-start" to VMLObject(mapOf(
                        "unit" to "point",
                        "value" to 100
                )),
                "padding-end" to VMLObject(mapOf(
                        "unit" to "point",
                        "value" to 100
                )),
                "padding-top" to VMLObject(mapOf(
                        "unit" to "point",
                        "value" to 100
                )),
                "padding-bottom" to VMLObject(mapOf(
                        "unit" to "point",
                        "value" to 100
                )),
                "children" to VMLArray()
        )))

        val node = shadow.node
        assertEquals(node.flexDirection, YogaFlexDirection.ROW)
//        assertEquals(node.wrap, YogaWrap.WRAP)
        assertEquals(node.alignItems, YogaAlign.CENTER)
        assertEquals(node.alignContent, YogaAlign.CENTER)
        assertEquals(node.justifyContent, YogaJustify.CENTER)

        val density = context.resources.displayMetrics.density
        assertEquals(node.getPadding(YogaEdge.ALL).value, Math.round(density * 100f).toFloat())
        assertEquals(node.getPadding(YogaEdge.START).value, Math.round(density * 100f).toFloat())
        assertEquals(node.getPadding(YogaEdge.END).value, Math.round(density * 100f).toFloat())
        assertEquals(node.getPadding(YogaEdge.TOP).value, Math.round(density * 100f).toFloat())
        assertEquals(node.getPadding(YogaEdge.BOTTOM).value, Math.round(density * 100f).toFloat())
    }

    @Test(expected = IllegalArgumentException::class)
    fun testChildrenRequired() {
        val shadow = YogaShadowView(context, null)
        shadow.setProps(VMLObject(mapOf()))
    }

    @Test
    fun testDefaults() {
        val shadow = YogaShadowView(context, null)
        shadow.setProps(VMLObject(mapOf("children" to VMLArray())))

        val node = shadow.node
        assertEquals(node.flexDirection, YogaFlexDirection.ROW)
//        assertEquals(node.wrap, YogaWrap.NO_WRAP)
        assertEquals(node.alignItems, YogaAlign.STRETCH)
        assertEquals(node.alignContent, YogaAlign.STRETCH)
        assertEquals(node.justifyContent, YogaJustify.FLEX_START)

        assertEquals(node.getPadding(YogaEdge.ALL).unit, YogaUnit.UNDEFINED)
        assertEquals(node.getPadding(YogaEdge.START).unit, YogaUnit.UNDEFINED)
        assertEquals(node.getPadding(YogaEdge.END).unit, YogaUnit.UNDEFINED)
        assertEquals(node.getPadding(YogaEdge.TOP).unit, YogaUnit.UNDEFINED)
        assertEquals(node.getPadding(YogaEdge.BOTTOM).unit, YogaUnit.UNDEFINED)
    }
}
