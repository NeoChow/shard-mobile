/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shards

import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.PrimaryKey

data class ShardSettings(
        val display: String,
        val position: String
)

@Entity data class Shard(
        @PrimaryKey val id : String,
        val title: String,
        val url: String,
        val description: String?,
        @Embedded val settings: ShardSettings
)
