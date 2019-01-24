package app.visly.shard

import java.lang.Exception

class Result<T> private constructor(private val success: T?, private val error: Exception?) {

    companion object {
        fun <T> success(success: T): Result<T> {
            return Result(success, null)
        }

        fun <T> error(error: Exception): Result<T> {
            return Result(null, error)
        }
    }

    fun isError(): Boolean {
        return error != null
    }

    fun isSuccess(): Boolean {
        return success != null
    }

    fun error(): Exception {
        return error!!
    }

    fun success(): T {
        return success!!
    }
}