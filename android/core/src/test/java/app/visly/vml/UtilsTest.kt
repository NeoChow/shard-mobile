/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import android.graphics.Color
import app.visly.vml.parseColor
import com.facebook.soloader.SoLoader
import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class UtilsTest {

    @Test
    fun testParseColor() {
        assertEquals(parseColor("#F00"), Color.RED)
        assertEquals(parseColor("#FF0000"), Color.RED)
        assertEquals(parseColor("#FFFF0000"), Color.RED)
    }
}
