/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml

import android.app.Application
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import com.facebook.common.internal.DoNotStrip
import com.facebook.drawee.backends.pipeline.Fresco
import com.facebook.soloader.SoLoader
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import okhttp3.Request
import app.visly.vml.viewimpl.FlexboxViewImpl
import app.visly.vml.viewimpl.ImageViewImpl
import app.visly.vml.viewimpl.TextViewImpl
import app.visly.vml.viewimpl.SolidColorViewImpl
import app.visly.vml.viewimpl.ScrollViewImpl

class VMLViewManager internal constructor() {

    companion object {
        private var hasCalledInit = false
        lateinit var instance: VMLViewManager private set


        fun init(app: Application) {
            if (!hasCalledInit) {
                SoLoader.init(app, false)
                Fresco.initialize(app)
                SoLoader.loadLibrary("vml")

                instance = VMLViewManager()
                instance.rustPtr = instance.bind()
                hasCalledInit = true
            }
        }
    }

    @DoNotStrip private var rustPtr: Long = 0
    private fun finalize() { free() }
    private external fun bind(): Long
    private external fun free()
    private external fun render(ctx: Context, json: String): Long

    private val httpClient = OkHttpClient()
    internal val implFactories: MutableMap<String, (Context) -> VMLViewImpl<View>> = mutableMapOf()

    init {
        setViewImpl("flexbox") { FlexboxViewImpl(it) }
        setViewImpl("image") { ImageViewImpl(it) }
        setViewImpl("text") { TextViewImpl(it) }
        setViewImpl("solid-color") { SolidColorViewImpl(it) }
        setViewImpl("scroll") { ScrollViewImpl(it) }
    }

    fun loadUrl(ctx: Context, url: String, completion: (VMLRoot) -> Unit) {
        assert(hasCalledInit) { "Must call VMLViewManager.init() from your Application class" }

        val handler = Handler(Looper.getMainLooper())
        GlobalScope.launch {
            val request = Request.Builder()
                    .url(url)
                    .header("content-type", "application/vml")
                    .build()

            val response = httpClient.newCall(request).execute()
            val json = response.body()!!.string()
            handler.post { completion(loadJson(ctx, json)) }
        }
    }

    fun loadJson(ctx: Context, json: JsonValue): VMLRoot {
        return loadJson(ctx, json.toString())
    }

    fun loadJson(ctx: Context, json: String): VMLRoot {
        assert(hasCalledInit) { "Must call VMLViewManager.init() from your Application class" }
        return VMLRoot(ctx, render(ctx, json))
    }

    @Suppress("UNCHECKED_CAST")
    fun setViewImpl(kind: String, implFactory: (Context) -> VMLViewImpl<out View>) {
        implFactories[kind] = implFactory as (Context) -> VMLViewImpl<View>
    }

    @DoNotStrip private fun createView(ctx: Context, kind: String): VMLView {
        return VMLView(ctx, implFactories[kind]!!(ctx))
    }
}