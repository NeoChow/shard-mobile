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
import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ScrollViewImplTest {
    lateinit var context: ShardContext

    @Before
    fun setup() {
        context = ShardContext(ApplicationProvider.getApplicationContext())
    }

    @Test
    fun testSetDirectionHorizontal() {
        val viewImpl = ScrollViewImpl(context)
        viewImpl.setProp("direction", JsonValue.String("horizontal"))
        assertEquals(viewImpl.direction, ScrollViewImpl.Direction.HORIZONTAL)
    }

    @Test
    fun testSetDirectionVertical() {
        val viewImpl = ScrollViewImpl(context)
        viewImpl.setProp("direction", JsonValue.String("vertical"))
        assertEquals(viewImpl.direction, ScrollViewImpl.Direction.VERTICAL)
    }

    @Test
    fun testSetContentInset() {
        val viewImpl = ScrollViewImpl(context)
        viewImpl.setProp("content-inset", JsonValue.Object(mapOf(
                "unit" to JsonValue.String("points"),
                "value" to JsonValue.Number(10f)
        )))
        assertEquals(viewImpl.contentInset, 10)
    }
}
