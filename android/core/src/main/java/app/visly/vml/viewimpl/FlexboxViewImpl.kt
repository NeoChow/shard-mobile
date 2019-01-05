package app.visly.vml.viewimpl

import android.content.Context
import app.visly.vml.AbsoluteLayout
import app.visly.vml.JsonValue
import app.visly.vml.Size

class FlexboxViewImpl(ctx: Context): BaseViewImpl<AbsoluteLayout>(ctx) {
    override fun measure(width: Float?, height: Float?): Size {
        return Size(width ?: 0f, height ?: 0f)
    }

    override fun setProp(key: String, value: JsonValue) {
        super.setProp(key, value)
    }

    override fun createView(): AbsoluteLayout {
        return AbsoluteLayout(ctx)
    }

    override fun bindView(view: AbsoluteLayout) {
        super.bindView(view)
    }
}
