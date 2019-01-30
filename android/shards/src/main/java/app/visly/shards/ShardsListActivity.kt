/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 
package app.visly.shards

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.lang.IllegalArgumentException
import android.view.*
import android.widget.FrameLayout
import android.widget.PopupWindow
import app.visly.shard.JsonValue
import app.visly.shard.ShardRootView
import app.visly.shard.ShardViewManager

class ShardsListActivity : AppCompatActivity(), ActivityCompat.OnRequestPermissionsResultCallback {

    lateinit var adapter: ShardsListAdapter
    var showingShard = false

    companion object {
        const val CAMERA_PERMISSION = 0
    }

    private fun isEmulator(): Boolean {
        return (Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")
                || "google_sdk" == Build.PRODUCT)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_shards_list)

        if (isEmulator()) {
            val toolbar = findViewById<Toolbar>(R.id.toolbar)
            toolbar.inflateMenu(R.menu.activity_shards_list)
            toolbar.setOnMenuItemClickListener {
                when (it.itemId) {
                    R.id.action_localhost -> {
                        showShard(Shard(
                                id = "localhost",
                                title = "localhost",
                                url = "http://10.0.2.2:3000",
                                description = null,
                                settings = ShardSettings(display = "popup", position = "center")
                        ))
                        true
                    }
                    else -> throw IllegalArgumentException()
                }
            }
        }

        val list = findViewById<RecyclerView>(R.id.list)
        list.layoutManager = LinearLayoutManager(this)
        adapter = ShardsListAdapter(this)
        adapter.setPermissionGranted(ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED)
        list.adapter = adapter

        val divider = DividerItemDecoration(this, DividerItemDecoration.VERTICAL)
        divider.setDrawable(getDrawable(R.drawable.divider)!!)
        list.addItemDecoration(divider)

        ShardsDatabase.instance(this)?.apply {
            GlobalScope.launch(context = Dispatchers.Main) {
                val shards = async(context = Dispatchers.Default) {
                    shardDao().getShards().toMutableList()
                }
                adapter.shards = shards.await()
            }
        }

        ShardService.instance.getExamples().enqueue(object: Callback<List<Shard>> {
            override fun onResponse(call: Call<List<Shard>>, response: Response<List<Shard>>) {
                adapter.examples = response.body()!!
            }

            override fun onFailure(call: Call<List<Shard>>, t: Throwable) {}
        })
    }

    fun didRequestPermission() {
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), CAMERA_PERMISSION)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == CAMERA_PERMISSION) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                adapter.setPermissionGranted(true)
            }
        }
    }

    fun showShard(shard: Shard) {
        val popupView = layoutInflater.inflate(R.layout.shard_popup, null, false)
        val shardRoot = popupView.findViewById<ShardRootView>(R.id.shard_root)
        val activityRoot = findViewById<View>(android.R.id.content)

        val popWindow = PopupWindow(
                popupView,
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
                true)

        shardRoot.layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                when (shard.settings.position) {
                    "top" -> Gravity.TOP
                    "bottom" -> Gravity.BOTTOM
                    else -> Gravity.CENTER
                }
        )

        popWindow.isFocusable = true
        popWindow.showAtLocation(activityRoot, Gravity.CENTER, 0, 0)
        popWindow.setOnDismissListener { showingShard = false }
        showingShard = true

        ShardViewManager.instance.loadUrl(this, shard.url) {
            if (it.isError()) {
                it.error().printStackTrace()
            } else {
                shardRoot.setRoot(it.success())
            }
        }

        shardRoot.on("open-url") {
            val url = (it as JsonValue.String).value
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
        }

        shardRoot.on("dismiss-alert") {
            popWindow.dismiss()
        }

        popupView.setOnClickListener {
            popWindow.dismiss()
        }
    }
}

class ShardsListAdapter(val activity: ShardsListActivity): RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    class ScannerViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val scanner: ScanView = view.findViewById(R.id.scan)
    }

    class HeaderViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val label: TextView = view.findViewById(R.id.label)
    }

    class ShardViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val title: TextView = view.findViewById(R.id.title)
        val subtitle: TextView = view.findViewById(R.id.subtitle)
    }

    var shards: MutableList<Shard> = mutableListOf()
        set(value) {
            field = value
            notifyDataSetChanged()
        }

    var examples: List<Shard> = listOf()
        set(value) {
            field = value
            notifyDataSetChanged()
        }

    private val inflater = LayoutInflater.from(activity)
    private var cameraPermissionGranted: Boolean = false

    init {
        setHasStableIds(true)
    }

    companion object {
        const val VIEW_TYPE_SCANNER = 0
        const val VIEW_TYPE_HEADER = 1
        const val VIEW_TYPE_SHARD = 2

        const val ID_SCANNER = 0L
        const val ID_HEADER_EXAMPLES = 1L
        const val ID_HEADER_SHARDS = 2L

        const val SHARD_OFFSET = 2
    }

    override fun getItemCount(): Int {
        return  1 /* scanner */ +
                1 /* examples header */ +
                1 /* shards header */ +
                shards.size + examples.size
    }

    fun shardAtPosition(position: Int): Shard {
        return if (position < SHARD_OFFSET + examples.size) {
            examples[position - SHARD_OFFSET]
        } else {
            shards[position - SHARD_OFFSET - examples.size - 1]
        }
    }

    override fun getItemId(position: Int): Long {
        return when (position) {
            0 -> ID_SCANNER
            1 -> ID_HEADER_EXAMPLES
            SHARD_OFFSET + examples.size -> ID_HEADER_SHARDS
            else -> shardAtPosition(position).url.hashCode().toLong()
        }
    }

    override fun getItemViewType(position: Int): Int {
        return when (position) {
            0 -> VIEW_TYPE_SCANNER
            1, SHARD_OFFSET + examples.size -> VIEW_TYPE_HEADER
            else -> VIEW_TYPE_SHARD
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            VIEW_TYPE_SCANNER -> ScannerViewHolder(inflater.inflate(R.layout.list_item_scan, parent, false))
            VIEW_TYPE_HEADER -> HeaderViewHolder(inflater.inflate(R.layout.list_item_header, parent, false))
            VIEW_TYPE_SHARD -> ShardViewHolder(inflater.inflate(R.layout.list_item_shard, parent, false))
            else -> throw IllegalArgumentException()
        }
    }

    override fun onBindViewHolder(vh: RecyclerView.ViewHolder, position: Int) {
        when (vh) {
            is ScannerViewHolder -> {
                vh.scanner.setHasPermission(cameraPermissionGranted)
                vh.scanner.delegate.didRequestPermission = activity::didRequestPermission
                vh.scanner.delegate.didScanShard = { instance, revision ->
                    if (!activity.showingShard) {
                        activity.showingShard = true

                        ShardService.instance.getShard(instance, revision).enqueue(object: Callback<Shard> {
                            override fun onResponse(call: Call<Shard>, response: Response<Shard>) {
                                val shard = response.body()!!

                                val handler = Handler(Looper.getMainLooper())
                                GlobalScope.launch {
                                    ShardsDatabase.instance(activity)?.apply {
                                        with(shardDao()) {
                                            try {
                                                insertShard(shard)
                                                handler.post {
                                                    shards.add(0, shard)
                                                    notifyItemInserted(0)
                                                }
                                            } catch (ignored: Exception) { }
                                        }
                                    }
                                }

                                activity.showShard(shard)
                            }

                            override fun onFailure(call: Call<Shard>, t: Throwable) {}
                        })
                    }
                }
            }

            is HeaderViewHolder -> {
                if (position == 1) {
                    vh.label.text = activity.getString(R.string.examples)
                } else {
                    vh.label.text = activity.getString(R.string.my_shards)
                }
            }

            is ShardViewHolder -> {
                val shard = shardAtPosition(position)
                vh.title.text = shard.title
                vh.subtitle.text = shard.description ?: shard.url
                vh.itemView.setOnClickListener {
                    activity.showShard(shard)
                }
            }
        }
    }

    fun setPermissionGranted(granted: Boolean) {
        this.cameraPermissionGranted = granted
        notifyItemChanged(0)
    }
}
