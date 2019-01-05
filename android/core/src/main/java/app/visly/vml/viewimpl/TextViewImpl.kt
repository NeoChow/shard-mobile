package app.visly.vml.viewimpl

import android.content.Context
import android.widget.TextView
import app.visly.vml.JsonValue
import app.visly.vml.Size

class TextViewImpl(ctx: Context): BaseViewImpl<TextView>(ctx) {
    override fun measure(width: Float?, height: Float?): Size {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun setProp(key: String, value: JsonValue) {
        super.setProp(key, value)
    }

    override fun createView(): TextView {
        return TextView(ctx)
    }

    override fun bindView(view: TextView) {
        super.bindView(view)
    }
}