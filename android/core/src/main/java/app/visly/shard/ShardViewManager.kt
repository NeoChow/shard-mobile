/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shard

import android.app.Application
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.annotation.Keep
import com.facebook.drawee.backends.pipeline.Fresco
import com.facebook.soloader.SoLoader
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import okhttp3.Request
import app.visly.shard.viewimpl.FlexboxViewImpl
import app.visly.shard.viewimpl.ImageViewImpl
import app.visly.shard.viewimpl.TextViewImpl
import app.visly.shard.viewimpl.SolidColorViewImpl
import app.visly.shard.viewimpl.ScrollViewImpl

class ShardViewManager internal constructor() {

    companion object {
        private var hasCalledInit = false
        lateinit var instance: ShardViewManager private set


        fun init(app: Application) {
            if (!hasCalledInit) {
                SoLoader.init(app, false)
                Fresco.initialize(app)
                SoLoader.loadLibrary("shard")

                instance = ShardViewManager()
                instance.rustPtr = instance.bind()
                hasCalledInit = true
            }
        }
    }

    @Keep private var rustPtr: Long = 0
    private fun finalize() { free() }
    private external fun bind(): Long
    private external fun free()
    private external fun render(ctx: Context, json: String): Long

    private val httpClient = OkHttpClient()
    internal val implFactories: MutableMap<String, (ShardContext) -> ShardViewImpl<View>> = mutableMapOf()

    init {
        setViewImpl("flexbox") { FlexboxViewImpl(it) }
        setViewImpl("image") { ImageViewImpl(it) }
        setViewImpl("text") { TextViewImpl(it) }
        setViewImpl("solid-color") { SolidColorViewImpl(it) }
        setViewImpl("scroll") { ScrollViewImpl(it) }
    }

    fun loadUrl(ctx: Context, url: String, completion: (ShardRoot) -> Unit) {
        assert(hasCalledInit) { "Must call ShardViewManager.init() from your Application class" }

        val handler = Handler(Looper.getMainLooper())
        GlobalScope.launch {
            val request = Request.Builder()
                    .url(url)
                    .header("content-type", "application/shard")
                    .build()

            val response = httpClient.newCall(request).execute()
            val json = response.body()!!.string()
            handler.post { completion(loadJson(ctx, json)) }
        }
    }

    fun loadJson(ctx: Context, json: JsonValue): ShardRoot {
        return loadJson(ctx, json.toString())
    }

    fun loadJson(ctx: Context, json: String): ShardRoot {
        assert(hasCalledInit) { "Must call ShardViewManager.init() from your Application class" }
        val ctx = ShardContext(ctx)
        return ShardRoot(ctx, render(ctx, json))
    }

    @Suppress("UNCHECKED_CAST")
    fun setViewImpl(kind: String, implFactory: (ShardContext) -> ShardViewImpl<out View>) {
        implFactories[kind] = implFactory as (ShardContext) -> ShardViewImpl<View>
    }

    @Keep private fun createView(ctx: ShardContext, kind: String): ShardView {
        return ShardView(ctx, implFactories[kind]!!(ctx))
    }
}