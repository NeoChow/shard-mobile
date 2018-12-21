/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package app.visly

import app.visly.shadowview.*

typealias ShadowViewConstructor = (ctx: VMLContext, parent: ShadowViewParent?) -> ShadowView

class VMLConfig private constructor(
        internal val shadowViewsConstructors: Map<String, ShadowViewConstructor>) {

    companion object {
        internal var default: VMLConfig = Builder().build()
    }

    fun makeDefault() {
        default = this
    }

    class Builder {
        val shadowViewsConstructors: MutableMap<String, ShadowViewConstructor> = mutableMapOf()

        init {
            addView("flexbox") { ctx, parent -> YogaShadowView(ctx, parent) }
            addView("text") { ctx, parent -> TextShadowView(ctx, parent) }
            addView("image") { ctx, parent -> ImageShadowView(ctx, parent) }
            addView("scroll") { ctx, parent -> ScrollShadowView(ctx, parent)}
            addView("solid-color") { ctx, parent -> SolidColorShadowView(ctx, parent)}
        }

        fun addView(kind: String, constructor: ShadowViewConstructor): Builder {
            shadowViewsConstructors[kind] = constructor
            return this
        }

        fun build(): VMLConfig = VMLConfig(shadowViewsConstructors)
    }
}
