/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly

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
class VMLConfigTest {

    @Before
    fun setup() {
        SoLoader.setInTestMode()
    }

    @Test
    fun testMakeDefault() {
        val oldDefault = VMLConfig.default
        val newConfig = VMLConfig.Builder().build()

        assertEquals(oldDefault, VMLConfig.default)
        newConfig.makeDefault()
        assertNotEquals(oldDefault, VMLConfig.default)
        assertEquals(newConfig, VMLConfig.default)
    }

    @Test
    fun ensureCorrectDefaults() {
        val config = VMLConfig.Builder().build()
        assertTrue(config.shadowViewsConstructors.count() == 5)
        assertTrue(config.shadowViewsConstructors.containsKey("image"))
        assertTrue(config.shadowViewsConstructors.containsKey("text"))
        assertTrue(config.shadowViewsConstructors.containsKey("solid-color"))
        assertTrue(config.shadowViewsConstructors.containsKey("flexbox"))
        assertTrue(config.shadowViewsConstructors.containsKey("scroll"))
    }
}
