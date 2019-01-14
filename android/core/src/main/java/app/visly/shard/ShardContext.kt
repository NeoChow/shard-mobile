package app.visly.shard

import android.content.Context
import android.content.ContextWrapper

internal interface ActionDelegate {
    fun on(action: String, value: JsonValue?)
}

class ShardContext(ctx: Context) : ContextWrapper(ctx) {
    internal var actionDelegate: ActionDelegate? = null

    fun dispatch(action: String, value: JsonValue?) {
        this.actionDelegate?.on(action, value)
    }
}