package app.visly.vml

import android.annotation.TargetApi
import android.content.Context
import android.os.Build
import android.util.AttributeSet

typealias ActionHandler = (JsonValue?) -> Unit

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
class VMLRootView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0, defStyleRes: Int = 0) : AbsoluteLayout(context, attrs, defStyleAttr, defStyleRes) {
    private var root: VMLRoot? = null
    private val actionHandlers: MutableMap<String, ActionHandler> = mutableMapOf()
    private val actionDelegate: ActionDelegate = object: ActionDelegate {
        override fun on(action: String, value: JsonValue?) {
            actionHandlers[action]?.invoke(value)
        }
    }

    fun setRoot(root: VMLRoot) {
        val oldRoot = this.root
        this.root = root

        oldRoot?.apply {
            oldRoot.ctx.actionDelegate = null
            removeView(this.view)
        }

        root.ctx.actionDelegate = actionDelegate
        addView(root.view)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        val widthMode = MeasureSpec.getMode(widthMeasureSpec)
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val heightMode = MeasureSpec.getMode(heightMeasureSpec)
        val height = MeasureSpec.getSize(heightMeasureSpec)


        val root = this.root
        if (root != null) {
            val size = root.measure(
                    if (widthMode == MeasureSpec.UNSPECIFIED) null else width.toFloat(),
                    if (heightMode == MeasureSpec.UNSPECIFIED) null else height.toFloat())

            measureChildren(
                    MeasureSpec.makeMeasureSpec(size.width.toInt(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(size.height.toInt(), MeasureSpec.EXACTLY))

            setMeasuredDimension(size.width.toInt(), size.height.toInt())
        } else {
            setMeasuredDimension(width, height)
        }
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        val root = this.root
        root?.view?.layout(0, 0, root.view.measuredWidth, root.view.measuredHeight)
    }

    fun on(action: String, callback: ActionHandler) {
        actionHandlers[action] = callback
    }

    fun off(action: String) {
        actionHandlers.remove(action)
    }
}