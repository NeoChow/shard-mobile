package app.visly.vml

import android.graphics.RectF
import com.facebook.soloader.SoLoader

private data class Size(val width: Float, val height: Float)

class View(val kind: String) {
    companion object {
        init {
            SoLoader.loadLibrary("vml")
        }
    }

    internal val rustPtr: Long = bind()
    private var frame: RectF = RectF()
    private var children: MutableList<View> = mutableListOf()
    private var props: MutableMap<String, String> = mutableMapOf()

    private external fun bind(): Long

    private fun setFrame(start: Float, end: Float, top: Float, bottom: Float) {
        this.frame = RectF(start, top, end, bottom)
    }

    private fun addChild(child: View) {
        children.add(child)
    }

    private fun setProp(key: String, value: String) {
        props.put(key, value)
    }

    private fun measure(width: Float, height: Float): Size {
        return Size(100f, 100f)
    }
}