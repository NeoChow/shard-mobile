package app.visly.vml.viewimpl

import android.content.Context
import app.visly.vml.JsonValue
import app.visly.vml.Size
import com.facebook.drawee.view.SimpleDraweeView

class ImageViewImpl(ctx: Context): BaseViewImpl<SimpleDraweeView>(ctx) {
    override fun measure(width: Float?, height: Float?): Size {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun setProp(key: String, value: JsonValue) {
        super.setProp(key, value)
    }

    override fun createView(): SimpleDraweeView {
        return SimpleDraweeView(ctx)
    }

    override fun bindView(view: SimpleDraweeView) {
        super.bindView(view)
    }
}