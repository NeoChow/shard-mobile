/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly

import com.facebook.yoga.YogaConfig
import org.robolectric.annotation.Implementation
import org.robolectric.annotation.Implements

@Implements(YogaConfig::class)
class ShadowYogaConfig {

    @Implementation
    protected fun __constructor__() {}

    @Implementation
    protected fun setUseWebDefaults(useWebDefaults: Boolean) {}
}