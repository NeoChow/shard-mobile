/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shadowview

import android.graphics.drawable.Animatable
import android.view.View
import app.visly.Size
import app.visly.VMLContext
import app.visly.VMLObject
import app.visly.toPixels
import com.facebook.drawee.backends.pipeline.Fresco
import com.facebook.drawee.controller.BaseControllerListener
import com.facebook.drawee.drawable.ScalingUtils
import com.facebook.drawee.generic.RoundingParams
import com.facebook.drawee.view.SimpleDraweeView
import com.facebook.imagepipeline.image.ImageInfo

class ImageShadowView(ctx: VMLContext, parent: ShadowViewParent?): ShadowView(ctx, parent) {
    private val image: SimpleDraweeView by lazy {
        val image = SimpleDraweeView(ctx)
        image.controller = Fresco.newDraweeControllerBuilder()
                .setOldController(image.controller)
                .setControllerListener(object : BaseControllerListener<ImageInfo>() {
                    override fun onFinalImageSet(id: String?, imageInfo: ImageInfo?, animatable: Animatable?) {
                        if (imageInfo != null) {
                            imageSize = Size(imageInfo.width, imageInfo.height)
                            parent?.requestLayout(this@ImageShadowView)
                        }
                    }
                })
                .build()
        image
    }

    private var src: String? = null
    private var scaleType: ScalingUtils.ScaleType = ScalingUtils.ScaleType.CENTER
    private var roundingParams: RoundingParams? = null

    private var imageSize: Size = Size(0, 0)
    private var baseProps: BaseShadowViewProps? = null

    override fun setProps(props: VMLObject) {
        baseProps = BaseShadowViewProps(ctx, props)

        src = props.get("src") {
            when (it) {
                is String -> it
                null -> throw IllegalArgumentException("src cannot be undefined")
                else -> throw IllegalArgumentException("Unexpected value for src: $it")
            }
        }

        scaleType = props.get("content-mode") {
            when (it) {
                "cover" -> ScalingUtils.ScaleType.CENTER_CROP
                "contain" -> ScalingUtils.ScaleType.CENTER_INSIDE
                null, "center" -> ScalingUtils.ScaleType.CENTER
                else -> throw IllegalArgumentException("Unexpected value for content-mode: $it")
            }
        }

        roundingParams = props.get("border-radius") {
            when (it) {
                is VMLObject -> RoundingParams.fromCornersRadius(it.toPixels(ctx.resources))
                "max" -> RoundingParams.asCircle()
                null -> null
                else -> throw IllegalArgumentException("Unexpected value for border-radius: $it")
            }
        }
    }

    override fun measure(widthMeasureSpec: Int, heightMeasureSpec: Int): Size {
        return imageSize
    }

    override fun getView(): View {
        baseProps?.applyTo(image)
        image.hierarchy.actualImageScaleType = scaleType
        image.hierarchy.roundingParams = roundingParams
        image.setImageURI(src)
        return image
    }
}