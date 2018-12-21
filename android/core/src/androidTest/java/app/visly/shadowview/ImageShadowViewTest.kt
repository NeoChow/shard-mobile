/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.app.Application
import androidx.test.annotation.UiThreadTest
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.visly.*
import com.facebook.drawee.drawable.ScalingUtils
import com.facebook.drawee.generic.RoundingParams
import com.facebook.drawee.view.SimpleDraweeView
import junit.framework.Assert.assertEquals
import org.junit.Test
import org.junit.Before
import org.junit.runner.RunWith
import java.lang.IllegalArgumentException

@RunWith(AndroidJUnit4::class)
class ImageShadowViewTest {

    private lateinit var context: VMLContext

    @Before
    fun setup() {
        val appContext = InstrumentationRegistry.getInstrumentation().context.applicationContext
        VML.init(appContext as Application)
        val root = VMLRootView(appContext)
        context = VMLContext(root, VMLConfig.default)
    }

    @Test
    @UiThreadTest
    fun testProps() {
        val shadow = ImageShadowView(context, null)
        shadow.setProps(VMLObject(mapOf(
                "src" to "https://visly.app",
                "content-mode" to "cover",
                "border-radius" to "max"
        )))

        val view = shadow.getView() as SimpleDraweeView
//        verify(view).setImageURI("https://visly.app")

        assertEquals(view.hierarchy.actualImageScaleType, ScalingUtils.ScaleType.CENTER_CROP)
        assertEquals(view.hierarchy.roundingParams, RoundingParams.asCircle())
    }

    @Test(expected = IllegalArgumentException::class)
    @UiThreadTest
    fun testSrcRequired() {
        val shadow = ImageShadowView(context, null)
        shadow.setProps(VMLObject(mapOf()))
    }

    @Test
    @UiThreadTest
    fun testDefaults() {
        val shadow = ImageShadowView(context, null)
        shadow.setProps(VMLObject(mapOf(
                "src" to "https://visly.app"
        )))

        val view = shadow.getView() as SimpleDraweeView
//        verify(view).setImageURI("https://visly.app")

        assertEquals(view.hierarchy.actualImageScaleType, ScalingUtils.ScaleType.CENTER)
        assertEquals(view.hierarchy.roundingParams, null)
    }
}
