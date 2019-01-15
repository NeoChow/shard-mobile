/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard.viewimpl

import androidx.test.core.app.ApplicationProvider
import app.visly.shard.JsonValue
import app.visly.shard.ShardContext
import com.facebook.drawee.drawable.ScalingUtils
import com.facebook.drawee.generic.RoundingParams
import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ImageViewImplTest {
    lateinit var context: ShardContext

    @Before
    fun setup() {
        context = ShardContext(ApplicationProvider.getApplicationContext())
    }

    @Test
    fun testSetSrc() {
        val viewImpl = ImageViewImpl(context)
        viewImpl.setProp("src", JsonValue.String("https://shardlib.com"))
        assertEquals(viewImpl.src, "https://shardlib.com")
    }

    @Test
    fun testSetContentModeCover() {
        val viewImpl = ImageViewImpl(context)
        viewImpl.setProp("content-mode", JsonValue.String("cover"))
        assertEquals(viewImpl.scaleType, ScalingUtils.ScaleType.CENTER_CROP)
    }

    @Test
    fun testSetContentModeContain() {
        val viewImpl = ImageViewImpl(context)
        viewImpl.setProp("content-mode", JsonValue.String("contain"))
        assertEquals(viewImpl.scaleType, ScalingUtils.ScaleType.CENTER_INSIDE)
    }

    @Test
    fun testSetContentModeCenter() {
        val viewImpl = ImageViewImpl(context)
        viewImpl.setProp("content-mode", JsonValue.String("center"))
        assertEquals(viewImpl.scaleType, ScalingUtils.ScaleType.CENTER)
    }

    @Test
    fun testSetBorderRadius() {
        val viewImpl = ImageViewImpl(context)
        viewImpl.setProp("border-radius", JsonValue.Object(mapOf(
                "unit" to JsonValue.String("points"),
                "value" to JsonValue.Number(10f)
        )))
        assertEquals(viewImpl.roundingParams, RoundingParams.fromCornersRadius(10f))
    }

    @Test
    fun testSetBorderRadiusMax() {
        val viewImpl = ImageViewImpl(context)
        viewImpl.setProp("border-radius", JsonValue.String("max"))
        assertEquals(viewImpl.roundingParams, RoundingParams.asCircle())
    }
}
