/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shards

import android.os.Bundle
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import app.visly.vml.VMLViewManager

class ShardActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_shard)

//        val title = intent.extras!!.getString("title")!!
//        val instance = intent.extras!!.getString("instance")!!
//        val revision = intent.extras!!.getInt("revision")!!

        val toolbar: Toolbar = findViewById(R.id.toolbar)
        toolbar.inflateMenu(R.menu.activity_shard)
        toolbar.title = title

        toolbar.setNavigationOnClickListener {
            finish()
        }

        val vmlView = VMLViewManager.instance.loadJson(this,"""{
            "root": {
                "kind": "flexbox",
                "props": {"background-color": "#000000"},

                "layout": {
                    "width": {"unit": "points", "value": 400},
                    "height": {"unit": "points", "value": 400}
                },

                "children": [
                    {
                        "kind": "image",

                        "props": {
                            "src": "https://placekitten.com/400/400",
                            "border-radius": {"unit": "points", "value": 20}
                        },

                        "layout": {
                            "width": {"unit": "percent", "value": 1},
                            "height": {"unit": "percent", "value": 1}
                        }
                    }
                ]
            }
        }""")

        val root: FrameLayout = findViewById(R.id.vml_root)
        root.addView(vmlView.getView(this))
    }
}