/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shards

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase


@Database(entities = [Shard::class], version = 1, exportSchema = false)
abstract class ShardsDatabase : RoomDatabase() {
    abstract fun shardDao(): ShardDao

    companion object {
        var INSTANCE: ShardsDatabase? = null

        fun instance(context: Context): ShardsDatabase? {
            if (INSTANCE == null){
                synchronized(ShardsDatabase::class) {
                    INSTANCE = Room.databaseBuilder(context.applicationContext, ShardsDatabase::class.java, "shardsDB").build()
                }
            }
            return INSTANCE
        }
    }
}