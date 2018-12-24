/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package app.visly

import android.app.Application
import android.util.Log
import com.facebook.drawee.backends.pipeline.Fresco
import com.facebook.soloader.SoLoader

class VML {
    companion object {
        fun init(app: Application) {
            SoLoader.init(app, false)
            Fresco.initialize(app)

            SoLoader.loadLibrary("vml")

            VML().getKind("{\"kind\": \"test\"}", object : StringCallback {
                override fun result(result: String) {
                    Log.d("vml", result)
                }
            })
        }
    }

    interface StringCallback {
        fun result(result: String)
    }

    external fun getKind(json: String, callback: StringCallback)
}