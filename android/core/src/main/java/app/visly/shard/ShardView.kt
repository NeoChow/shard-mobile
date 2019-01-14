/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard

import android.graphics.RectF
import android.view.View
import com.facebook.common.internal.DoNotStrip
import kotlin.math.ceil

interface ShardViewImpl<T: View> {
    fun measure(width: Float?, height: Float?): Size
    fun setProp(key: String, value: JsonValue)
    fun createView(): T
    fun bindView(view: T)
}

class ShardView(private val ctx: ShardContext, internal val impl: ShardViewImpl<View>) {
    @DoNotStrip private val rustPtr = bind()
    private fun finalize() { free() }
    private external fun bind(): Long
    private external fun free()

    internal var frame: RectF = RectF()
    internal var children: MutableList<ShardView> = mutableListOf()

    internal fun getSize() = Size(frame.right - frame.left, frame.bottom - frame.top)

    internal val view: View by lazy {
        impl.createView()
    }

    @DoNotStrip private fun setFrame(start: Float, end: Float, top: Float, bottom: Float) {
        val density = ctx.resources.displayMetrics.density
        this.frame = RectF(start * density, top * density, end * density, bottom * density)
    }

    @DoNotStrip private fun addChild(child: ShardView) {
        children.add(child)
    }

    @DoNotStrip private fun setProp(key: String, value: String) {
        impl.setProp(key, JsonValue.parse(value))
    }

    @DoNotStrip private fun measure(width: Float, height: Float): Size {
        val density = ctx.resources.displayMetrics.density
        val size = impl.measure(
                if (width.isNaN()) null else width * density,
                if (height.isNaN()) null else height * density)
        return Size(ceil(size.width / density), ceil(size.height / density))
    }
}