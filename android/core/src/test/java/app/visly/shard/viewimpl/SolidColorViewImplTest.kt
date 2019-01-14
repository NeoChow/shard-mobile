/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard.viewimpl

import android.view.View
import androidx.test.core.app.ApplicationProvider
import app.visly.shard.ShardContext
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.mockito.Mockito.*
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SolidColorViewImplTest {
    lateinit var context: ShardContext

    @Before
    fun setup() {
        context = ShardContext(ApplicationProvider.getApplicationContext())
    }

    @Test
    fun testDoesNothing() {
        val viewImpl = SolidColorViewImpl(context)
        val view = mock(View::class.java)
        viewImpl.bindView(view)
        Mockito.verify(view).setOnClickListener(null)
        verify(view).background = Mockito.any()
        verify(view).foreground = Mockito.any()
        verifyNoMoreInteractions(view)
    }
}
