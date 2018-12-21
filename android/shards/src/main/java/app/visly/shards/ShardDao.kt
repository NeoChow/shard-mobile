/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shards

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query

@Dao interface ShardDao {
    @Insert fun insertShard(shard: Shard)
    @Query("SELECT * FROM Shard") fun getShards(): List<Shard>
}