/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import androidx.test.core.app.ApplicationProvider
import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class VMLContextTest {
    lateinit var context: VMLContext

    @Before
    fun setup() {
        context = VMLContext(ApplicationProvider.getApplicationContext())
    }

    @Test
    fun testDispatchNull() {
        var action: String? = null
        var value: JsonValue? = null

        context.actionDelegate = object: ActionDelegate {
            override fun on(_action: String, _value: JsonValue?) {
                action = _action
                value = _value
            }
        }

        context.dispatch("click", null)
        assertEquals(action, "click")
        assertEquals(value, null)
    }

    @Test
    fun testDispatchValue() {
        var action: String? = null
        var value: JsonValue? = null

        context.actionDelegate = object: ActionDelegate {
            override fun on(_action: String, _value: JsonValue?) {
                action = _action
                value = _value
            }
        }

        context.dispatch("click", JsonValue.String("hello"))
        assertEquals(action, "click")
        assertEquals(value, JsonValue.String("hello"))
    }
}
