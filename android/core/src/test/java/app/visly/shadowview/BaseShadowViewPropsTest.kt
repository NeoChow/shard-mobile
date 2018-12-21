/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.graphics.drawable.StateListDrawable
import android.view.View
import androidx.test.core.app.ApplicationProvider
import app.visly.*
import com.facebook.soloader.SoLoader
import org.junit.Test
import org.junit.Before
import org.junit.runner.RunWith
import org.mockito.Matchers
import org.mockito.Mockito.*
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class BaseShadowViewPropsTest {

    private lateinit var context: VMLContext

    @Before
    fun setup() {
        SoLoader.setInTestMode()
        val root = VMLRootView(ApplicationProvider.getApplicationContext())
        context = VMLContext(root, VMLConfig.default)
    }

    @Test
    fun testSetBackground() {
        val baseProps = BaseShadowViewProps(context, VMLObject(mapOf(
                "background-color" to VMLObject(mapOf(
                        "default" to "#F00",
                        "pressed" to "#F00"
                ))
        )))

        val view = mock(View::class.java)
        baseProps.applyTo(view)

        verify(view).background = Matchers.isA(StateListDrawable::class.java)
    }

    @Test
    fun testSetTapAction() {
        val baseProps = BaseShadowViewProps(context, VMLObject(mapOf(
                "tap-action" to "test"
        )))

        val view = mock(View::class.java)
        baseProps.applyTo(view)

        verify(view).setOnClickListener(Matchers.any())
    }

    @Test
    fun testDefaults() {
        val baseProps = BaseShadowViewProps(context, VMLObject(mapOf()))
        val view = mock(View::class.java)
        baseProps.applyTo(view)
        verifyZeroInteractions(view)
    }
}
