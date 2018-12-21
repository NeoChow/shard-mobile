/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.graphics.Rect
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import app.visly.*
import com.facebook.yoga.*

class YogaShadowView(ctx: VMLContext, parent: ShadowViewParent?): ShadowViewParent(ctx, parent) {
    companion object {
        internal val config: YogaConfig = YogaConfig()

        init {
            config.setUseWebDefaults(true)
        }
    }

    private val container: ViewGroup by lazy { FrameLayout(ctx) }
    private var baseProps: BaseShadowViewProps? = null
    internal val node: YogaNode = YogaNode(config)
    private val children = mutableListOf<Pair<YogaNode, ShadowView>>()

    override fun setProps(props: VMLObject) {
        baseProps = BaseShadowViewProps(ctx, props)

        props.get("flex-direction") {
            when (it) {
                "row" -> node.flexDirection = YogaFlexDirection.ROW
                "column" -> node.flexDirection = YogaFlexDirection.COLUMN
                null -> { }
                else -> throw IllegalArgumentException("Unexpected value for flex-direction: $it")
            }
        }

        props.get("flex-wrap") {
            when (it) {
                "nowrap" -> node.setWrap(YogaWrap.NO_WRAP)
                "wrap" -> node.setWrap(YogaWrap.WRAP)
                "wrap-reverse" -> node.setWrap(YogaWrap.WRAP_REVERSE)
                null -> { }
                else -> throw IllegalArgumentException("Unexpected value for flex-wrap: $it")
            }
        }

        props.get("align-items") {
            when (it) {
                "stretch" -> node.alignItems = YogaAlign.STRETCH
                "flex-start" -> node.alignItems = YogaAlign.FLEX_START
                "flex-end" -> node.alignItems = YogaAlign.FLEX_END
                "center" -> node.alignItems = YogaAlign.CENTER
                null -> { }
                else -> throw IllegalArgumentException("Unexpected value for align-items: $it")
            }
        }

        props.get("align-content") {
            when (it) {
                "stretch" -> node.alignContent = YogaAlign.STRETCH
                "flex-start" -> node.alignContent = YogaAlign.FLEX_START
                "flex-end" -> node.alignContent = YogaAlign.FLEX_END
                "space-between" -> node.alignContent = YogaAlign.SPACE_BETWEEN
                "space-around" -> node.alignContent = YogaAlign.SPACE_AROUND
                "center" -> node.alignContent = YogaAlign.CENTER
                null -> { }
                else -> throw IllegalArgumentException("Unexpected value for align-content: $it")
            }
        }

        props.get("justify-content") {
            when (it) {
                "center" -> node.justifyContent = YogaJustify.CENTER
                "flex-start" -> node.justifyContent = YogaJustify.FLEX_START
                "flex-end" -> node.justifyContent = YogaJustify.FLEX_END
                "space-between" -> node.justifyContent = YogaJustify.SPACE_BETWEEN
                "space-around" -> node.justifyContent = YogaJustify.SPACE_AROUND
                null -> { }
                else -> throw IllegalArgumentException("Unexpected value for justify-content: $it")
            }
        }

        val setPadding = { prop: String, edge: YogaEdge ->
            props.get(prop) {
                when (it) {
                    is VMLObject -> {
                        val value = it.toYogaValue(ctx.resources)
                        when (value.unit) {
                            YogaUnit.POINT -> node.setPadding(edge, value.value)
                            YogaUnit.PERCENT -> node.setPaddingPercent(edge, value.value)
                            else -> {}
                        }
                    }
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for $prop: $it")
                }
            }
        }

        setPadding("padding", YogaEdge.ALL)
        setPadding("padding-start", YogaEdge.START)
        setPadding("padding-end", YogaEdge.END)
        setPadding("padding-top", YogaEdge.TOP)
        setPadding("padding-bottom", YogaEdge.BOTTOM)

        val children = props.get("children") {
            when (it) {
                is VMLArray -> it
                else -> throw IllegalArgumentException("Unexpected value for children: $it")
            }
        }

        this.children.removeAll { true }
        for (i in 0 until this.node.childCount) { node.removeChildAt(0) }

        for (i in 0 until children.length()) {
            val child = children.get(i) {
                when (it) {
                    is VMLObject -> it
                    else -> throw IllegalArgumentException("Unexpected value for child: $it")
                }
            }

            val kind = child.get("kind") {
                when (it) {
                    is String -> it
                    else -> throw IllegalArgumentException("Unexpected value for kind: $it")
                }
            }

            val props = child.get("props") {
                when (it) {
                    is VMLObject -> it
                    else -> throw IllegalArgumentException("Unexpected value for props: $it")
                }
            }

            val childShadowView = ctx.createShadowView(kind, this)
            childShadowView.setProps(props)

            val childNode: YogaNode = if (childShadowView is YogaShadowView) {
                childShadowView.node
            } else {
                val node = YogaNode(YogaShadowView.config)
                node.data = childShadowView
                node.setMeasureFunction(ViewMeasureFunction())
                node
            }

            val layout = child.get("layout") {
                when (it) {
                    is VMLObject -> it
                    null -> VMLObject()
                    else -> throw IllegalArgumentException("Unexpected value for layout: $it")
                }
            }

            layout.get("position") {
                when (it) {
                    "relative" -> childNode.positionType = YogaPositionType.RELATIVE
                    "absolute" -> childNode.positionType = YogaPositionType.ABSOLUTE
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for position: $it")
                }
            }

            val setPosition = { prop: String, edge: YogaEdge ->
                layout.get(prop) {
                    when (it) {
                        is VMLObject -> {
                            val value = it.toYogaValue(ctx.resources)
                            when (value.unit) {
                                YogaUnit.POINT -> childNode.setPosition(edge, value.value)
                                YogaUnit.PERCENT -> childNode.setPositionPercent(edge, value.value)
                                else -> {}
                            }
                        }
                        null -> { }
                        else -> throw IllegalArgumentException("Unexpected value for $prop: $it")
                    }
                }
            }

            setPosition("start", YogaEdge.START)
            setPosition("end", YogaEdge.END)
            setPosition("top", YogaEdge.TOP)
            setPosition("bottom", YogaEdge.BOTTOM)

            val setMargin = { prop: String, edge: YogaEdge ->
                layout.get(prop) {
                    when (it) {
                        is VMLObject -> {
                            val value = it.toYogaValue(ctx.resources)
                            when (value.unit) {
                                YogaUnit.POINT -> childNode.setMargin(edge, value.value)
                                YogaUnit.PERCENT -> childNode.setMarginPercent(edge, value.value)
                                else -> {}
                            }
                        }
                        "auto" -> childNode.setMarginAuto(edge)
                        null -> { }
                        else -> throw IllegalArgumentException("Unexpected value for $prop: $it")
                    }
                }
            }

            setMargin("margin", YogaEdge.ALL)
            setMargin("margin-start", YogaEdge.START)
            setMargin("margin-end", YogaEdge.END)
            setMargin("margin-top", YogaEdge.TOP)
            setMargin("margin-bottom", YogaEdge.BOTTOM)

            layout.get("width") {
                when (it) {
                    is VMLObject -> {
                        val value = it.toYogaValue(ctx.resources)
                        when (value.unit) {
                            YogaUnit.POINT -> childNode.setWidth(value.value)
                            YogaUnit.PERCENT -> childNode.setWidthPercent(value.value)
                            else -> {}
                        }
                    }
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for width: $it")
                }
            }

            layout.get("min-width") {
                when (it) {
                    is VMLObject -> {
                        val value = it.toYogaValue(ctx.resources)
                        when (value.unit) {
                            YogaUnit.POINT -> childNode.setMinWidth(value.value)
                            YogaUnit.PERCENT -> childNode.setMinWidthPercent(value.value)
                            else -> {}
                        }
                    }
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for min-width: $it")
                }
            }

            layout.get("max-width") {
                when (it) {
                    is VMLObject -> {
                        val value = it.toYogaValue(ctx.resources)
                        when (value.unit) {
                            YogaUnit.POINT -> childNode.setMaxWidth(value.value)
                            YogaUnit.PERCENT -> childNode.setMaxWidthPercent(value.value)
                            else -> {}
                        }
                    }
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for max-width: $it")
                }
            }

            layout.get("height") {
                when (it) {
                    is VMLObject -> {
                        val value = it.toYogaValue(ctx.resources)
                        when (value.unit) {
                            YogaUnit.POINT -> childNode.setHeight(value.value)
                            YogaUnit.PERCENT -> childNode.setHeightPercent(value.value)
                            else -> {}
                        }
                    }
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for height: $it")
                }
            }

            layout.get("min-height") {
                when (it) {
                    is VMLObject -> {
                        val value = it.toYogaValue(ctx.resources)
                        when (value.unit) {
                            YogaUnit.POINT -> childNode.setMinHeight(value.value)
                            YogaUnit.PERCENT -> childNode.setMinHeightPercent(value.value)
                            else -> {}
                        }
                    }
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for min-height: $it")
                }
            }

            layout.get("max-height") {
                when (it) {
                    is VMLObject -> {
                        val value = it.toYogaValue(ctx.resources)
                        when (value.unit) {
                            YogaUnit.POINT -> childNode.setMaxHeight(value.value)
                            YogaUnit.PERCENT -> childNode.setMaxHeightPercent(value.value)
                            else -> {}
                        }
                    }
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for max-height: $it")
                }
            }

            layout.get("flex-grow") {
                when (it) {
                    is Number -> childNode.flexGrow = it.toFloat()
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for flex-grow: $it")
                }
            }

            layout.get("flex-shrink") {
                when (it) {
                    is Number -> childNode.flexShrink = it.toFloat()
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for flex-shrink: $it")
                }
            }

            layout.get("flex-basis") {
                when (it) {
                    is VMLObject -> {
                        val value = it.toYogaValue(ctx.resources)
                        when (value.unit) {
                            YogaUnit.POINT -> childNode.setFlexBasis(value.value)
                            YogaUnit.PERCENT -> childNode.setFlexBasisPercent(value.value)
                            else -> {}
                        }
                    }
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for flex-basis: $it")
                }
            }

            layout.get("align-self") {
                when (it) {
                    "stretch" -> childNode.alignSelf = YogaAlign.STRETCH
                    "flex-start" -> childNode.alignSelf = YogaAlign.FLEX_START
                    "flex-end" -> childNode.alignSelf = YogaAlign.FLEX_END
                    "center" -> childNode.alignSelf = YogaAlign.CENTER
                    "auto" -> childNode.alignSelf = YogaAlign.AUTO
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for align-self: $it")
                }
            }

            layout.get("aspect-ratio") {
                when (it) {
                    is Number -> childNode.aspectRatio = it.toFloat()
                    null -> { }
                    else -> throw IllegalArgumentException("Unexpected value for aspect-ratio: $it")
                }
            }

            node.addChildAt(childNode, this.children.size)
            this.children.add(Pair(childNode, childShadowView))
        }
    }

    override fun measure(widthMeasureSpec: Int, heightMeasureSpec: Int): Size {
        if (node.owner == null) {
          calculateLayout(widthMeasureSpec, heightMeasureSpec)
        }
        return Size(node.layoutWidth.toInt(), node.layoutHeight.toInt())
    }

    override fun getView(): View {
        container.removeAllViews()

        for (child in children) {
            val shadow = child.second
            val params = FrameLayout.LayoutParams(shadow.frame.width(), shadow.frame.height())
            params.leftMargin = shadow.frame.left
            params.topMargin = shadow.frame.top
            container.addView(shadow.getView(), params)
        }

        baseProps?.applyTo(container)
        return container
    }

    override fun layoutChildren() {
        measure(View.MeasureSpec.makeMeasureSpec(frame.width(), View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(frame.height(), View.MeasureSpec.EXACTLY))

        for (child in children) {
            val x = child.first.layoutX.toInt()
            val y = child.first.layoutY.toInt()
            val width = child.first.layoutWidth.toInt()
            val height = child.first.layoutHeight.toInt()
            child.second.frame = Rect(x, y, x + width, y + height)

            if (child.second is ShadowViewParent) {
                (child.second as ShadowViewParent).layoutChildren()
            }
        }
    }

    override fun requestLayout(dirtyChild: ShadowView) {
        parent?.requestLayout(this)

        for (child in children) {
            if (child.second == dirtyChild && child.first.isMeasureDefined) {
                child.first.dirty()
                break
            }
        }
    }

    private fun calculateLayout(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val widthSize = View.MeasureSpec.getSize(widthMeasureSpec)
        val heightSize = View.MeasureSpec.getSize(heightMeasureSpec)
        val widthMode = View.MeasureSpec.getMode(widthMeasureSpec)
        val heightMode = View.MeasureSpec.getMode(heightMeasureSpec)

        if (heightMode == View.MeasureSpec.EXACTLY) {
            node.setHeight(heightSize.toFloat())
        }

        if (widthMode == View.MeasureSpec.EXACTLY) {
            node.setWidth(widthSize.toFloat())
        }

        if (heightMode == View.MeasureSpec.AT_MOST) {
            node.setMaxHeight(heightSize.toFloat())
        }

        if (widthMode == View.MeasureSpec.AT_MOST) {
            node.setMaxWidth(widthSize.toFloat())
        }

        node.calculateLayout(YogaConstants.UNDEFINED, YogaConstants.UNDEFINED)
    }

    /**
     * Wrapper around measure function for yoga leaves.
     */
    private class ViewMeasureFunction : YogaMeasureFunction {

        /**
         * A function to measure leaves of the Yoga tree.  Yoga needs some way to know how large
         * elements want to be.  This function passes that question directly through to the relevant
         * `View`'s measure function.
         *
         * @param node The yoga node to measure
         * @param width The suggested width from the owner
         * @param widthMode The type of suggestion for the width
         * @param height The suggested height from the owner
         * @param heightMode The type of suggestion for the height
         * @return A measurement output (`YogaMeasureOutput`) for the node
         */
        override fun measure(
                node: YogaNode,
                width: Float,
                widthMode: YogaMeasureMode,
                height: Float,
                heightMode: YogaMeasureMode): Long {
            val view = node.data as ShadowView? ?: return YogaMeasureOutput.make(0, 0)

            val widthMeasureSpec = View.MeasureSpec.makeMeasureSpec(
                    width.toInt(),
                    viewMeasureSpecFromYogaMeasureMode(widthMode))
            val heightMeasureSpec = View.MeasureSpec.makeMeasureSpec(
                    height.toInt(),
                    viewMeasureSpecFromYogaMeasureMode(heightMode))

            val size = view.measure(widthMeasureSpec, heightMeasureSpec)
            return YogaMeasureOutput.make(size.width, size.height)
        }

        private fun viewMeasureSpecFromYogaMeasureMode(mode: YogaMeasureMode): Int {
            return if (mode == YogaMeasureMode.AT_MOST) {
                View.MeasureSpec.AT_MOST
            } else if (mode == YogaMeasureMode.EXACTLY) {
                View.MeasureSpec.EXACTLY
            } else {
                View.MeasureSpec.UNSPECIFIED
            }
        }
    }
}