package app.visly.vml

import com.facebook.soloader.SoLoader

class ViewManager {
    companion object {
        init {
            SoLoader.loadLibrary("vml")
        }
    }

    private external fun bind(): Long
    private external fun render(rustPtr: Long, json: String): View

    internal val rustPtr: Long = bind()

    fun render(json: String): View {
        return render(rustPtr, json)
    }

    private fun createView(kind: String): View {
        return View(kind)
    }
}