/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import com.facebook.soloader.SoLoader
import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class VMLViewManagerTest {

    @Before
    fun setup() {
        SoLoader.setInTestMode()
    }

    @Test
    fun testDefaults() {
        val vm = VMLViewManager()
        assertEquals(vm.implFactories.size, 5)
        assertTrue(vm.implFactories.contains("text"))
        assertTrue(vm.implFactories.contains("flexbox"))
        assertTrue(vm.implFactories.contains("image"))
        assertTrue(vm.implFactories.contains("scroll"))
        assertTrue(vm.implFactories.contains("solid-color"))
    }
}
