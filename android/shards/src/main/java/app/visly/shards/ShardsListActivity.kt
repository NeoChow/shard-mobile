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
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
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
import retrofit2.Retrofit

class ShardsListActivity : AppCompatActivity(), ActivityCompat.OnRequestPermissionsResultCallback {

    lateinit var adapter: ShardsListAdapter

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
                        startActivity(Intent(this, ShardActivity::class.java).apply {
                            putExtra("title", "localhost")
                            putExtra("instance", "http://10.0.2.2:3000")
                            putExtra("revision", 0)
                        })
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
                vh.scanner.delegate.didScanUrl = { url ->
                    if (url.host == "playground.shardlib.com") {
                        val parts = url.path.split("/")
                        val instance = parts[0]

                        ShardService.instance.getShard(instance).enqueue(object: Callback<Shard> {
                            override fun onResponse(call: Call<Shard>, response: Response<Shard>) {
                                val shard = response.body()!!
                                shards.add(0, shard)
                                notifyItemInserted(0)

                                val db = ShardsDatabase.instance(activity)
                                ShardsDatabase.instance(activity)?.apply {
                                    with(db?.shardDao()) {
                                        this?.insertShard(shard)
                                    }
                                }

                                startShardActivity(shard)
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
                    vh.label.text = activity.getString(R.string.previous_shards)
                }
            }

            is ShardViewHolder -> {
                val shard = shardAtPosition(position)
                vh.title.text = shard.title
                vh.subtitle.text = shard.url
                vh.itemView.setOnClickListener {
                    startShardActivity(shard)
                }
            }
        }
    }

    fun startShardActivity(shard: Shard) {
        activity.startActivity(Intent(activity, ShardActivity::class.java).apply {
            putExtra("title", shard.title)
            putExtra("url", shard.url)
        })
    }

    fun setPermissionGranted(granted: Boolean) {
        this.cameraPermissionGranted = granted
        notifyItemChanged(0)
    }
}
