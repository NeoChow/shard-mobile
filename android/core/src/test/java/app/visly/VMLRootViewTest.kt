/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly

import androidx.test.core.app.ApplicationProvider
import com.facebook.soloader.SoLoader
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class VMLRootViewTest {

    private lateinit var root: VMLRootView
    private lateinit var context: VMLContext

    @Before
    fun setup() {
        SoLoader.setInTestMode()
        root = VMLRootView(ApplicationProvider.getApplicationContext())
        context = VMLContext(root, VMLConfig.default)
    }

    @Test
    fun testDispatchEvent() {
        root.on("perform-action") {
            root.tag = "action performed"
        }

        context.dispatchEvent("perform-action", VMLObject())
        assertEquals(root.tag, "action performed")
    }

    @Test
    fun testRemoveEventHandler() {
        root.on("perform-action") {
            root.tag = "action performed"
        }
        root.on("perform-action", null)

        context.dispatchEvent("perform-action", VMLObject())
        assertNotEquals(root.tag, "action performed")
    }
}
