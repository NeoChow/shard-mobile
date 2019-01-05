/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml.viewimpl

import android.view.View
import androidx.test.core.app.ApplicationProvider
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mockito
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class FlexboxViewImplTest {

    @Test
    fun testDoesNothing() {
        val viewImpl = SolidColorViewImpl(ApplicationProvider.getApplicationContext())
        val view = Mockito.mock(View::class.java)
        viewImpl.bindView(view)
        Mockito.verify(view).background = Mockito.any()
        Mockito.verify(view).foreground = Mockito.any()
        Mockito.verifyNoMoreInteractions(view)
    }
}
