package app.visly.shard

import android.view.View
import androidx.annotation.Keep
import java.lang.RuntimeException

class ShardRoot(internal val ctx: ShardContext, @Keep internal val rustPtr: Long) {
    private fun finalize() { free() }
    private external fun free()
    private external fun getView(): ShardView
    private external fun measure(size: Size)

    fun measure(width: Float?, height: Float?): Size {
        val density = ctx.resources.displayMetrics.density
        measure(Size(width?.div(density) ?: Float.NaN, height?.div(density) ?: Float.NaN))

        fun updateFrame(root: ShardView) {
            val view = root.view
            view.layoutParams = AbsoluteLayout.LayoutParams(
                    root.frame.width().toInt(),
                    root.frame.height().toInt(),
                    root.frame.left.toInt(),
                    root.frame.top.toInt())

            if (view is AbsoluteLayout) {
                view.size = root.getSize()
                for (child in root.children) {
                    updateFrame(child)
                }
            }
        }

        updateFrame(getView())

        return getView().getSize()
    }

    internal val view: View by lazy {
        fun createHierarchy(root: ShardView): View {
            val view = root.view
            root.impl.bindView(view)

            if (view is AbsoluteLayout) {
                for (child in root.children) {
                    view.addView(createHierarchy(child))
                }
            } else if (root.children.size > 0) {
                throw RuntimeException("Only flexbox is allowed to specify children")
            }

            return view
        }

        createHierarchy(getView())
    }
}