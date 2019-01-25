/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard

import android.os.Looper
import androidx.test.core.app.ApplicationProvider
import com.facebook.soloader.SoLoader
import kotlinx.coroutines.runBlocking
import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ShardViewManagerTest {
    lateinit var context: ShardContext

    @Before
    fun setup() {
        SoLoader.setInTestMode()
        context = ShardContext(ApplicationProvider.getApplicationContext())
    }


    @Test
    fun testDefaults() {
        val vm = ShardViewManager()
        assertEquals(vm.implFactories.size, 5)
        assertTrue(vm.implFactories.contains("text"))
        assertTrue(vm.implFactories.contains("flexbox"))
        assertTrue(vm.implFactories.contains("image"))
        assertTrue(vm.implFactories.contains("scroll"))
        assertTrue(vm.implFactories.contains("solid-color"))
    }

    @Test
    fun testErrorWheInvalidUrl() {
        val vm = ShardViewManager()
        var result: Result<ShardRoot>? = null

        runBlocking {
            vm.loadUrl(context, "") {
                result = it
            }.join()
        }

        Robolectric.flushForegroundThreadScheduler()
        assertTrue(result!!.isError())
    }
}
