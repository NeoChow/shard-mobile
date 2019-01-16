package app.visly.shards

import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path

interface ShardService {
    companion object {
        val instance: ShardService by lazy {
            Retrofit.Builder()
                    .baseUrl("https://playground.shardlib.com/")
                    .addConverterFactory(GsonConverterFactory.create())
                    .build()
                    .create<ShardService>(ShardService::class.java)
        }
    }

    @GET("api/shards/{instance}/{revision}")
    fun getShard(@Path("instance") instance: String, @Path("revision") revision: String): Call<Shard>

    @GET("api/shards/examples")
    fun getExamples(): Call<List<Shard>>
}