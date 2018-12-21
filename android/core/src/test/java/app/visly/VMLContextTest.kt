/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly

import android.view.View
import android.widget.ImageView
import androidx.test.core.app.ApplicationProvider
import app.visly.shadowview.ShadowView
import com.facebook.soloader.SoLoader
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import java.lang.IllegalArgumentException

@RunWith(RobolectricTestRunner::class)
@Config(shadows = [ShadowYogaConfig::class, ShadowYogaNode::class])
class VMLContextTest {

    private lateinit var root: VMLRootView
    private lateinit var context: VMLContext

    @Before
    fun setup() {
        SoLoader.setInTestMode()
        root = VMLRootView(ApplicationProvider.getApplicationContext())
        context = VMLContext(root, VMLConfig.default)
    }

    @Test
    fun testCreateFlexbox() {
        context.createShadowView("flexbox", null)
    }

    @Test
    fun testCreateImage() {
        context.createShadowView("image", null)
    }

    @Test
    fun testCreateText() {
        context.createShadowView("text", null)
    }

    @Test
    fun testCreateSolidColor() {
        context.createShadowView("solid-color", null)
    }


    @Test
    fun testAddView() {
        val config = VMLConfig.Builder()
                .addView("Hello") { ctx, parent -> object: ShadowView(ctx, parent) {
                    override fun setProps(props: VMLObject) {}
                    override fun measure(widthMeasureSpec: Int, heightMeasureSpec: Int): Size {
                        return Size(0, 0)
                    }

                    override fun getView(): View {
                        val view = View(ctx)
                        view.tag = "hello"
                        return view
                    }

                }}
                .build()

        val context = VMLContext(root, config)
        val shadow = context.createShadowView("Hello", null)
        val view = shadow.getView()
        assertEquals(view.tag, "hello")
    }

    @Test(expected = IllegalArgumentException::class)
    fun testCreateViewWithUnkownKind() {
        context.createShadowView("hello", null)
    }
}
