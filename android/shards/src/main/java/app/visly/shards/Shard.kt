/**
 * Copyright (c) Visly Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package app.visly.shards

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity data class Shard(
        @PrimaryKey(autoGenerate = true) val id : Int? = null,
        val title: String,
        val instance: String,
        val revision: Int
)
