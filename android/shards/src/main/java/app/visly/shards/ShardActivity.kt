/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shards

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import app.visly.shard.ShardRootView
import app.visly.shard.ShardViewManager
import android.content.Intent
import android.net.Uri
import app.visly.shard.JsonValue


class ShardActivity : AppCompatActivity() {
    lateinit var root: ShardRootView
    lateinit var url: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_shard)

        url = intent.extras!!.getString("url")!!

        root = findViewById(R.id.shard_root)
        root.on("open-url") {
            val url = (it as JsonValue.String).value
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
        }

        val toolbar: Toolbar = findViewById(R.id.toolbar)
        toolbar.inflateMenu(R.menu.activity_shard)
        toolbar.title = intent.extras!!.getString("title")!!

        toolbar.setNavigationOnClickListener {
            finish()
        }

        toolbar.setOnMenuItemClickListener {
            if (it.itemId == R.id.action_refresh) {
                refresh()
                true
            } else {
                false
            }
        }

        refresh()
    }

    fun refresh() {
        ShardViewManager.instance.loadUrl(this, url) {
            root.setRoot(it)
        }
    }
}