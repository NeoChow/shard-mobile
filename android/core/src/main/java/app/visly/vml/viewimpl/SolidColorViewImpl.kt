/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml.viewimpl

import android.content.Context
import android.view.View
import app.visly.vml.JsonValue
import app.visly.vml.Size

class SolidColorViewImpl(ctx: Context): BaseViewImpl<View>(ctx) {
    override fun measure(width: Float?, height: Float?): Size {
        return Size(width ?: 0f, height ?: 0f)
    }

    override fun setProp(key: String, value: JsonValue) {
        super.setProp(key, value)
    }

    override fun createView(): View {
        return View(ctx)
    }

    override fun bindView(view: View) {
        super.bindView(view)
    }
}