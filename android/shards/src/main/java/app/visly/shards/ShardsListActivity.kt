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

    private val inflater = LayoutInflater.from(activity)
    private val service: ShardService
    private var cameraPermissionGranted: Boolean = false

    init {
        setHasStableIds(true)

        service = Retrofit.Builder()
                .baseUrl("https://playground.shardlib.com/")
                .build()
                .create<ShardService>(ShardService::class.java)
    }

    companion object {
        const val VIEW_TYPE_SCANNER = 0
        const val VIEW_TYPE_HEADER = 1
        const val VIEW_TYPE_SHARD = 2

        const val SHARD_OFFSET = 2
    }

    override fun getItemCount(): Int {
        return SHARD_OFFSET + shards.size
    }

    override fun getItemId(position: Int): Long {
        return when (position) {
            0 -> 0
            1 -> 1
            else -> (shards[position - SHARD_OFFSET].id!! + SHARD_OFFSET).toLong()
        }
    }

    override fun getItemViewType(position: Int): Int {
        return when (position) {
            0 -> VIEW_TYPE_SCANNER
            1 -> VIEW_TYPE_HEADER
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
                        val revision = parts[1].toInt()

                        service.getShard(instance).enqueue(object: Callback<ShardResponse> {
                            override fun onResponse(call: Call<ShardResponse>, response: Response<ShardResponse>) {
                                val shard = Shard(title = response.body()!!.title, instance = instance, revision = revision)

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

                            override fun onFailure(call: Call<ShardResponse>, t: Throwable) {}
                        })
                    }
                }
            }

            is HeaderViewHolder -> {
                vh.label.text = activity.getString(R.string.previous_shards)
            }

            is ShardViewHolder -> {
                val shard = shards[position - SHARD_OFFSET]
                vh.title.text = shard.title
                vh.subtitle.text = "https://playground.shardlib.com/${shard.instance}/${shard.revision}"
                vh.itemView.setOnClickListener {
                    startShardActivity(shard)
                }
            }
        }
    }

    fun startShardActivity(shard: Shard) {
        activity.startActivity(Intent(activity, ShardActivity::class.java).apply {
            putExtra("title", shard.title)
            putExtra("instance", shard.instance)
            putExtra("revision", shard.revision)
        })
    }

    fun setPermissionGranted(granted: Boolean) {
        this.cameraPermissionGranted = granted
        notifyItemChanged(0)
    }
}
