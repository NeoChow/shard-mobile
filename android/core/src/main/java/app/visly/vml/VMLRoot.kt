package app.visly.vml

import android.content.Context
import android.view.View
import com.facebook.common.internal.DoNotStrip
import java.lang.RuntimeException

class VMLRoot(private val ctx: Context, @DoNotStrip internal val rustPtr: Long) {
    private fun finalize() { free() }
    private external fun free()
    private external fun getView(): VMLView
    private external fun measure(size: Size)

    fun measure(width: Float?, height: Float?): Size {
        val density = ctx.resources.displayMetrics.density
        measure(Size(width?.div(density) ?: Float.NaN, height?.div(density) ?: Float.NaN))

        fun updateFrame(root: VMLView) {
            val view = root.view
            view.layoutParams = AbsoluteLayout.LayoutParams(
                    root.frame.width().toInt(),
                    root.frame.height().toInt(),
                    root.frame.left.toInt(),
                    root.frame.top.toInt())
            root.impl.bindView(view)

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
        fun createHierarchy(root: VMLView): View {
            val view = root.view

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