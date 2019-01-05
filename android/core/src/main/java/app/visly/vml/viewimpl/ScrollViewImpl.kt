package app.visly.vml.viewimpl

import android.content.Context
import android.widget.ScrollView
import app.visly.vml.JsonValue
import app.visly.vml.Size

class ScrollViewImpl(ctx: Context): BaseViewImpl<ScrollView>(ctx) {
    override fun measure(width: Float?, height: Float?): Size {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun setProp(key: String, value: JsonValue) {
        super.setProp(key, value)
    }

    override fun createView(): ScrollView {
        return ScrollView(ctx)
    }

    override fun bindView(view: ScrollView) {
        super.bindView(view)
    }
}