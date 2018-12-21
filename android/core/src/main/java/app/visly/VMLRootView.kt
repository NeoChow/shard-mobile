/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package app.visly

import android.content.Context
import android.graphics.Rect
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.util.Log
import android.widget.FrameLayout
import app.visly.shadowview.ShadowView
import app.visly.shadowview.ShadowViewParent
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject

typealias EventHandler = (data: VMLObject) -> Unit

class VMLRootView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) : FrameLayout(context, attrs, defStyleAttr) {
    private val httpClient = OkHttpClient()
    private val eventHandlers = mutableMapOf<String, EventHandler>()

    @JvmOverloads
    fun load(
            url: String,
            config: VMLConfig = VMLConfig.default,
            onComplete: (error: Throwable?) -> Unit = {
                it ?: Log.e("vml", it.toString())
            }) {
        val handler = Handler(Looper.getMainLooper())
        val context = VMLContext(this, config)

        GlobalScope.launch {
            try {
                val request = Request.Builder()
                        .url(url)
                        .header("content-type", "application/vml")
                        .build()

                val response = httpClient.newCall(request).execute()
                val vml = VMLObject(JSONObject(response.body()!!.string()))

                vml.get("version") {
                    when (it) {
                        is String -> Log.d("vml", "version: $it")
                        else -> throw IllegalArgumentException("Unexpected value for version: $it")
                    }
                }

                val root = vml.get("root") {
                    when (it) {
                        is VMLObject -> it
                        null -> null
                        else -> throw IllegalArgumentException("Unexpected value for root: $it")
                    }
                }

                val error = vml.get("error") {
                    when (it) {
                        is String -> Error(it)
                        null -> null
                        else -> throw IllegalArgumentException("Unexpected value for error: $it")
                    }
                }

                if (root === null) {
                    onComplete(error)
                } else {
                    val kind = root.get("kind") {
                        when (it) {
                            is String -> it
                            else -> throw IllegalArgumentException("Unexpected value for kind: $it")
                        }
                    }

                    val props = root.get("props") {
                        when (it) {
                            is VMLObject -> it
                            else -> throw IllegalArgumentException("Unexpected value for props: $it")
                        }
                    }

                    val shadow = context.createShadowView(kind, null)
                    shadow.setProps(props)
                    shadow.frame = Rect(0, 0, width, height)

                    if (shadow is ShadowViewParent) {
                        shadow.layoutChildren()
                    }

                    handler.post {
                        commitShadowView(shadow)
                        onComplete(error)
                    }
                }
            } catch (error: Throwable) {
                handler.post { onComplete(error) }
            }
        }
    }

    internal fun commitShadowView(shadow: ShadowView) {
        val view = shadow.getView()
        removeAllViews()
        addView(view)
    }

    internal fun dispatchEvent(type: String, data: VMLObject) {
        eventHandlers[type]?.invoke(data)
    }

    fun on(event: String, callback: EventHandler?) {
        if (callback === null) {
            eventHandlers.remove(event)
        } else {
            eventHandlers[event] = callback
        }
    }
}