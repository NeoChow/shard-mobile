/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.vml.viewimpl

import app.visly.vml.AbsoluteLayout
import app.visly.vml.Size
import app.visly.vml.VMLContext

class FlexboxViewImpl(ctx: VMLContext): BaseViewImpl<AbsoluteLayout>(ctx) {
    override fun measure(width: Float?, height: Float?): Size {
        return Size(width ?: 0f, height ?: 0f)
    }

    override fun createView(): AbsoluteLayout {
        return AbsoluteLayout(ctx)
    }
}
