/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import android.content.Context
import android.graphics.RectF
import android.view.View
import com.facebook.common.internal.DoNotStrip
import java.lang.RuntimeException

interface VMLViewImpl<T: View> {
    fun measure(width: Float?, height: Float?): Size
    fun setProp(key: String, value: JsonValue)
    fun createView(): T
    fun bindView(view: T)
}

class VMLView(val impl: VMLViewImpl<View>) {
    @DoNotStrip private val rustPtr = bind()
    private fun finalize() { free() }
    private external fun bind(): Long
    private external fun free()

    private var frame: RectF = RectF()
    private var children: MutableList<VMLView> = mutableListOf()

    fun getSize() = Size(frame.right - frame.left, frame.bottom - frame.top)

    fun getView(ctx: Context): View {
        val view = impl.createView()
        impl.bindView(view)

        if (view is AbsoluteLayout) {
            view.size = getSize()
            for (child in children) {
                view.addView(child.getView(ctx), AbsoluteLayout.LayoutParams(
                        child.frame.width().toInt(),
                        child.frame.height().toInt(),
                        child.frame.left.toInt(),
                        child.frame.top.toInt()))
            }
        } else if (children.size > 0) {
            throw RuntimeException("Only flexbox is allowed to specify children")
        }

        return view
    }

    @DoNotStrip private fun setFrame(start: Float, end: Float, top: Float, bottom: Float) {
        this.frame = RectF(start, top, end, bottom)
    }

    @DoNotStrip private fun addChild(child: VMLView) {
        children.add(child)
    }

    @DoNotStrip private fun setProp(key: String, value: String) {
        impl.setProp(key, JsonValue.parse(value))
    }

    @DoNotStrip private fun measure(width: Float, height: Float): Size {
        return impl.measure(
                if (width.isNaN()) null else width,
                if (height.isNaN()) null else height)
    }
}