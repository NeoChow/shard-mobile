package app.visly.shards

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Path

data class ShardResponse(val title: String)

interface ShardService {
    @GET("api/shards/{instance}")
    fun getShard(@Path("instance") instance: String): Call<ShardResponse>
}