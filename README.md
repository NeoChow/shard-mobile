# Shard Mobile libraries
[![CircleCI](https://circleci.com/gh/vislyhq/shard-mobile.svg?style=svg)](https://circleci.com/gh/vislyhq/shard-mobile)[ ![Download](https://api.bintray.com/packages/visly/maven/shard-android-client/images/download.svg) ](https://bintray.com/visly/maven/shard-android-client)[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/ShardKit/badge.png)](https://cocoadocs.org/docsets/ShardKit)

Mobile client libraries for https://shardlib.com. If you are interested in integrating it into your app feel free to contact us at hello@visly.app or post an issue on the repo.

## Overview
This repo contains both the Android and iOS libraries for Shard written in Kotlin/Swift as well as the shared core written in rust. The shared rust core manages the non platform specific aspects of rendering a Shard UI such as parsing the server response, efficiently managing updates, and performing layout. Layout is based on [flexbox using the stretch library](https://github.com/vislyhq/stretch).

## Getting started
### Android
To get started using Shard in your Android app just add the Shard core dependency. Also make sure to configure abi splits to ensure that only the required native libraries are bundled in your apk.

```groovy
android {
    splits {
        abi {
            enable true
        }
    }
}

dependencies {
    implementation 'app.visly.shard:core:0.1.5'
}
```

You also have to make sure to initialize the native dependencies, this is best done in your `Application` class.

```kotlin
class ShardsApplication: Application() {

    override fun onCreate() {
        super.onCreate()
        ShardViewManager.init(this)
    }
}
```

Now you're ready to load your first Shard view. Your can either load it via a url pointing to an endpoint on your server built with [node-shard-server](https://github.com/vislyhq/node-shard-server) or using a raw json string. We will use the raw json approach here for simplicity.

```kotlin
class MainActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val result = ShardViewManager.instance.loadJson(this, """{
            "root": {
                "kind": "flexbox",
                "props": {"background-color": "#f00"},
                "layout": {
                    "width": {"unit": "points", "value": 200},
                    "height": {"unit": "points", "value": 200}
                }
            }
        }""")

        val root: ShardRootView = findViewById(R.id.shard_root)
        root.setRoot(result)
    }
}
```

### iOS
To get started using Shard in your iOS app start by adding the cocoapods dependency.

```ruby
platform :ios, '11.0'
use_frameworks!

target 'ios' do
  pod 'ShardKit', '~> 0.1.5'
end
```

Now you're ready to load your first Shard view. Your can either load it via a url pointing to an endpoint on your server built with [node-shard-server](https://github.com/vislyhq/node-shard-server) or using a raw json string. We will use the raw json approach here for simplicity.

```swift
import UIKit
import ShardKit

class ViewController: UIViewController {
    @IBOutlet weak var shardRoot: ShardRootView!
    
    override func viewDidLoad() {
        let result = ShardViewManager.shared.loadJson("""
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

        self.shardRoot.setRoot(result)
    }
}
```

## Developing
Start by installing the Android and iOS toolchains by downloading Xcode and Android studio. For android you will also need to set your `$ANDROID_HOME`. Right now we only support building on macOS, however you can use the shard library via jcenter / cocoapods on any platform.

Once you have the Android and iOS toolchains installed it's time to clone the repo and get setup. We have prepared a few Make scripts to hopefully simplify this process. These scripts prepare your local environment for building the rust core. If you are just planning on developing in Kotlin / Swift then there is no need to run any of the make scripts.

```bash
git clone https://github.com/vislyhq/shard-mobile.git
cd shard-mobile
make setup
make install
```

Once that is all done you should be good to go. Open `shard-mobile/ios/Examples/ShardKit.xcworkspace` in Xcode or `shard-mobile/android` in Android Studio.

All the shared rust code is located in `shard-mobile/core` with platform bindings in `shard-mobile/core/ios` and `shard-mobile/core/android`. After making any edits to rust files make sure to run `make install` from the root directory to build and package the rust library for use in Android and iOS.

If you want to make any changes or additions to the layout engine powering Shard head over to [github.com/vislyhq/stretch](https://github.com/vislyhq/stretch).

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
