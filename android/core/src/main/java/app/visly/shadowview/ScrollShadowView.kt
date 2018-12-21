/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.graphics.Rect
import android.view.View
import android.widget.HorizontalScrollView
import android.widget.ScrollView
import app.visly.Size
import app.visly.VMLContext
import app.visly.VMLObject
import app.visly.toPixels

class ScrollShadowView(ctx: VMLContext, parent: ShadowViewParent?): ShadowViewParent(ctx, parent) {
    private enum class Direction {
        VERTICAL,
        HORIZONTAL,
    }

    private var direction: Direction? = null
    private var contentInset: Rect? = null
    private var content: ShadowView? = null
    private var baseProps: BaseShadowViewProps? = null

    override fun setProps(props: VMLObject) {
        baseProps = BaseShadowViewProps(ctx, props)

        direction = props.get("direction") {
            when (it) {
                "horizontal" -> Direction.HORIZONTAL
                "vertical" -> Direction.VERTICAL
                else -> throw IllegalArgumentException("Unexpected value for direction: $it")
            }
        }

        contentInset = props.get("content-inset") {
            when (it) {
                is VMLObject -> {
                    val padding = it.toPixels(ctx.resources).toInt()
                    Rect(if (direction == Direction.HORIZONTAL) padding else 0,
                         if (direction == Direction.VERTICAL) padding else 0,
                         if (direction == Direction.HORIZONTAL) padding else 0,
                         if (direction == Direction.VERTICAL) padding else 0)
                }
                null -> null
                else -> throw IllegalArgumentException("Unexpected value for content-inset: $it")
            }
        }

        content = props.get("content") {
            when (it) {
                is VMLObject -> {
                    val shadow = ctx.createShadowView(it.get("kind") {
                        when (it) {
                            is String -> it
                            else -> throw IllegalArgumentException("Unexpected value for kind: $it")
                        }
                    }, this)

                    shadow.setProps(it.get("props") {
                        when (it) {
                            is VMLObject -> it
                            else -> throw IllegalArgumentException("Unexpected value for props: $it")
                        }
                    })

                    shadow
                }
                else -> throw IllegalArgumentException("Unexpected value for content: $it")
            }
        }
    }

    override fun measure(widthMeasureSpec: Int, heightMeasureSpec: Int): Size {
        val content = content

        if (content != null) {
            val widthSpec = if (direction == Direction.HORIZONTAL) {
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            } else {
                widthMeasureSpec
            }

            val heightSpec = if (direction == Direction.VERTICAL) {
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            } else {
                heightMeasureSpec
            }

            return content.measure(widthSpec, heightSpec)
        } else {
            val width = Math.max(0, View.MeasureSpec.getSize(widthMeasureSpec))
            val height = Math.max(0, View.MeasureSpec.getSize(heightMeasureSpec))
            return Size(width, height)
        }
    }

    override fun getView(): View {
        val scrollView = if (direction == Direction.VERTICAL) ScrollView(ctx) else HorizontalScrollView(ctx)
        scrollView.clipToPadding = false

        val insets = contentInset
        if (insets != null) {
            scrollView.setPadding(insets.left, insets.top, insets.right, insets.bottom)
        }

        scrollView.isHorizontalScrollBarEnabled = false
        scrollView.isVerticalScrollBarEnabled = false
        baseProps?.applyTo(scrollView)
        scrollView.addView(content?.getView())
        return scrollView
    }

    override fun layoutChildren() {
        val content = content

        if (content != null) {
            val widthSpec = if (direction == Direction.HORIZONTAL) {
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            } else {
                View.MeasureSpec.makeMeasureSpec(frame.width(), View.MeasureSpec.EXACTLY)
            }

            val heightSpec = if (direction == Direction.VERTICAL) {
                View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            } else {
                View.MeasureSpec.makeMeasureSpec(frame.height(), View.MeasureSpec.EXACTLY)
            }

            val size = content.measure(widthSpec, heightSpec)
            content.frame = Rect(0, 0, size.width, size.height)

            if (content is ShadowViewParent) {
                content.layoutChildren()
            }
        }
    }

    override fun requestLayout(dirtyChild: ShadowView) {
        parent?.requestLayout(this)
    }
}