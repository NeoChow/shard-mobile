/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml.viewimpl

import androidx.test.core.app.ApplicationProvider
import app.visly.vml.JsonValue
import com.facebook.drawee.drawable.ScalingUtils
import com.facebook.drawee.generic.RoundingParams
import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ImageViewImplTest {

    @Test
    fun testSetSrc() {
        val viewImpl = ImageViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("src", JsonValue.String("https://visly.app"))
        assertEquals(viewImpl.src, "https://visly.app")
    }

    @Test
    fun testSetContentModeCover() {
        val viewImpl = ImageViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("content-mode", JsonValue.String("cover"))
        assertEquals(viewImpl.scaleType, ScalingUtils.ScaleType.CENTER_CROP)
    }

    @Test
    fun testSetContentModeContain() {
        val viewImpl = ImageViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("content-mode", JsonValue.String("contain"))
        assertEquals(viewImpl.scaleType, ScalingUtils.ScaleType.CENTER_INSIDE)
    }

    @Test
    fun testSetContentModeCenter() {
        val viewImpl = ImageViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("content-mode", JsonValue.String("center"))
        assertEquals(viewImpl.scaleType, ScalingUtils.ScaleType.CENTER)
    }

    @Test
    fun testSetBorderRadius() {
        val viewImpl = ImageViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("border-radius", JsonValue.Object(mapOf(
                "unit" to JsonValue.String("points"),
                "value" to JsonValue.Number(10f)
        )))
        assertEquals(viewImpl.roundingParams, RoundingParams.fromCornersRadius(10f))
    }

    @Test
    fun testSetBorderRadiusMax() {
        val viewImpl = ImageViewImpl(ApplicationProvider.getApplicationContext())
        viewImpl.setProp("border-radius", JsonValue.String("max"))
        assertEquals(viewImpl.roundingParams, RoundingParams.asCircle())
    }
}
