# VML Mobile libraries
[![CircleCI](https://circleci.com/gh/vislyhq/vml-mobile.svg?style=svg)](https://circleci.com/gh/vislyhq/vml-mobile)

Mobile client libraries for https://visly.app. VML is currently in an experimental state so if you are interested in integrating it into your app please contact us at hello@visly.app so we can make sure it is a good fit and offer any assistance if needed.

VML is a cross-platform mobile framework for rendering server-side driven UIs. We want VML to be a replacement for webviews, with many of the same benefits but with native performance. Benefits of using VML include *over the air updates*, *cross platform*, *server-side controlled*.

## Overview
This repo contains both the Android and iOS libraries for VML written in Kotlin/Swift as well as the shared core written in rust. The shared rust core manages the non platform specific aspects of rendering a VML UI such as parsing the server response, efficiently managing updates, and performing layout. Layout is based on [flexbox using the stretch library](https://github.com/vislyhq/stretch).

## Getting started
### Android
To get started using `VML` in your Android app start by adding the jcenter dependency.

```groovy
dependencies {
    implementation 'app.visly.vml:core:0.1.1'
}
```

You also have to make sure to initialize the native dependencies, this is best done in your `Application` class.

```kotlin
class ShardsApplication: Application() {

    override fun onCreate() {
        super.onCreate()
        VMLViewManager.init(this)
    }
}
```

Now you're ready to load your first vml view. Your can either load it via a url pointing to an endpoint on your server built with [node-vml-server](https://github.com/vislyhq/node-vml-server) or using a raw json string. We will use the raw json approach here for simplicity.

```kotlin
class MainActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val result = VMLViewManager.instance.loadJson(this, """{
            "root": {
                "kind": "flexbox",
                "props": {"background-color": "#f00"},
                "layout": {
                    "width": {"unit": "points", "value": 200},
                    "height": {"unit": "points", "value": 200}
                }
            }
        }""")

        val root: FrameLayout = findViewById(R.id.vml_root)
        root.addView(result.getView(this))
    }
}
```

### iOS
To get started using `VML` in your iOS app start by adding the cocoapods dependency.

```ruby
platform :ios, '11.0'
use_frameworks!

target 'ios' do
  pod 'VMLKit', '~> 0.1.2'
end
```

Now you're ready to load your first vml view. Your can either load it via a url pointing to an endpoint on your server built with [node-vml-server](https://github.com/vislyhq/node-vml-server) or using a raw json string. We will use the raw json approach here for simplicity.

```swift
import UIKit
import VMLKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        let result = VMLViewManager.shared.loadJson("""
        {
            "root": {
                "kind": "flexbox",
                "props": {"background-color": "#f00"},
                "layout": {
                    "width": {"unit": "points", "value": 200},
                    "height": {"unit": "points", "value": 200}
                }
            }
        }
        """)

        self.view.addSubview(result.view)
    }
}
```

## Developing
Start by installing the Android and iOS toolchains by downloading Xcode and Android studio. For android you will also need to set your `$ANDROID_HOME`. Right now we only support building on macOS, however you can use the vml library via jcenter / cocoapods on any platform.

Once you have the Android and iOS toolchains installed it's time to clone the repo and get setup. We have prepared a few Make scripts to hopefully simpligy this process. These scripts prepare your local environment for building the rust core. If you are just planning on developing in Kotlin / Swift then there is no need to run any of the make scripts.

```bash
git clone https://github.com/vislyhq/vml-mobile.git
cd vml-mobile
make setup
make install
```

Once that is all done you should be good to go. Open `vml-mobile/ios/Examples/VMLKit.xcworkspace` in Xcode or `vml-mobile/android` in Android Studio.

All the shared rust code is located in `vml-mobile/core` with platform bindings in `vml-mobile/core/ios` and `vml-mobile/core/android`. After making any edits to rust files make sure to run `make install` from the root directory to build and package the rust library for use in Android and iOS.

If you want to make any changes or additions to the layout engine powering VML head over to [github.com/vislyhq/stretch](https://github.com/vislyhq/stretch).

# LICENCE
```
Copyright (c) 2018 Visly Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
