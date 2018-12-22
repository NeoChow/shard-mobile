/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package app.visly.shards

import android.app.Application
import app.visly.VML
import com.microsoft.appcenter.crashes.Crashes
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.AppCenter

class ShardsApplication: Application() {
    override fun onCreate() {
        super.onCreate()
        VML.init(this)
        if (!BuildConfig.APPCENTER_SECRET.isEmpty()) {
            AppCenter.start(this, BuildConfig.APPCENTER_SECRET, Analytics::class.java, Crashes::class.java)
        }
    }
}