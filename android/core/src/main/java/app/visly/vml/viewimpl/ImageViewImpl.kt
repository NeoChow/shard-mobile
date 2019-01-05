package app.visly.vml.viewimpl

import android.content.Context
import android.graphics.drawable.Animatable
import app.visly.vml.JsonValue
import app.visly.vml.Size
import app.visly.vml.toDips
import com.facebook.drawee.backends.pipeline.Fresco
import com.facebook.drawee.controller.BaseControllerListener
import com.facebook.drawee.drawable.ScalingUtils
import com.facebook.drawee.generic.RoundingParams
import com.facebook.drawee.view.SimpleDraweeView
import com.facebook.imagepipeline.image.ImageInfo

class ImageViewImpl(ctx: Context): BaseViewImpl<SimpleDraweeView>(ctx) {
    private var src: String? = null
    private var scaleType = ScalingUtils.ScaleType.CENTER
    private var roundingParams: RoundingParams? = null
    private var imageSize = Size(0f, 0f)

    override fun measure(width: Float?, height: Float?): Size {
        return Size(width ?: imageSize.width, height ?: imageSize.height)
    }

    override fun setProp(key: String, value: JsonValue) {
        super.setProp(key, value)

        when (key) {
            "src" -> {
                src = when (value) {
                    is JsonValue.String -> value.value
                    else -> null
                }
            }

            "content-mode" -> {
                scaleType = when (value) {
                    JsonValue.String("cover") -> ScalingUtils.ScaleType.CENTER_CROP
                    JsonValue.String("contain") -> ScalingUtils.ScaleType.CENTER_INSIDE
                    JsonValue.String("center") -> ScalingUtils.ScaleType.CENTER
                    else -> ScalingUtils.ScaleType.CENTER
                }
            }

            "border-radius" -> {
                roundingParams = when (value) {
                    JsonValue.String("max") -> RoundingParams.asCircle()
                    is JsonValue.Object -> RoundingParams.fromCornersRadius(value.toDips(ctx))
                    else -> null
                }
            }
        }
    }

    override fun createView(): SimpleDraweeView {
        val image = SimpleDraweeView(ctx)
        image.controller = Fresco.newDraweeControllerBuilder()
                .setOldController(image.controller)
                .setControllerListener(object : BaseControllerListener<ImageInfo>() {
                    override fun onFinalImageSet(id: String?, imageInfo: ImageInfo?, animatable: Animatable?) {
                        if (imageInfo != null) {
                            imageSize = Size(imageInfo.width.toFloat(), imageInfo.height.toFloat())
                            // TODO request new layout
                        }
                    }
                })
                .build()
        return image
    }

    override fun bindView(view: SimpleDraweeView) {
        super.bindView(view)
        view.hierarchy.actualImageScaleType = scaleType
        view.hierarchy.roundingParams = roundingParams
        view.setImageURI(src)
    }
}