/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard.viewimpl

import android.view.View
import android.widget.HorizontalScrollView
import android.widget.ScrollView
import app.visly.shard.*

class ScrollViewImpl(ctx: ShardContext): BaseViewImpl<View>(ctx) {
    internal enum class Direction {
        VERTICAL,
        HORIZONTAL,
    }

    internal var direction = Direction.VERTICAL
    internal var contentInset = 0
    internal var content: ShardRoot? = null

    override fun measure(width: Float?, height: Float?): Size {
        return content?.measure(width, height) ?: Size(width ?: 0f, height ?: 0f)
    }

    override fun setProp(key: String, value: JsonValue) {
        super.setProp(key, value)

        when (key) {
            "direction" -> {
                direction = when (value) {
                    JsonValue.String("horizontal") -> Direction.HORIZONTAL
                    JsonValue.String("vertical") -> Direction.VERTICAL
                    else -> Direction.VERTICAL
                }
            }

            "content-inset" -> {
                contentInset = when (value) {
                    is JsonValue.Object -> value.toDips(ctx).toInt()
                    else -> 0
                }
            }

            "content" -> {
                content = when (value) {
                    is JsonValue.Object -> ShardViewManager.instance.loadJson(ctx, value)
                    else -> null
                }
            }
        }
    }

    override fun createView(): View {
        val view = if (direction == Direction.VERTICAL) {
            ScrollView(ctx)
        } else {
            HorizontalScrollView(ctx)
        }

        view.clipToPadding = false
        view.isHorizontalScrollBarEnabled = false
        view.isVerticalScrollBarEnabled = false
        view.addView(ShardRootView(ctx))
        return view
    }

    override fun bindView(view: View) {
        super.bindView(view)
        val view = if (direction == Direction.VERTICAL) {
            view as ScrollView
        } else {
            view as HorizontalScrollView
        }

        view.setPadding(
                if (direction == Direction.VERTICAL) 0 else contentInset,
                if (direction == Direction.HORIZONTAL) 0 else contentInset,
                if (direction == Direction.VERTICAL) 0 else contentInset,
                if (direction == Direction.HORIZONTAL) 0 else contentInset)

        val content = content
        if (content != null) {
            val contentRoot = view.getChildAt(0) as ShardRootView
            contentRoot.setRoot(content)
        }
    }
}