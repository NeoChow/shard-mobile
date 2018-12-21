/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package app.visly.shards

import android.app.Application
import app.visly.VML

class ShardsApplication: Application() {
    override fun onCreate() {
        super.onCreate()
        VML.init(this)
    }
}