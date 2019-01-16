package app.visly.shards

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import com.google.zxing.BarcodeFormat
import com.google.zxing.ResultPoint
import com.journeyapps.barcodescanner.BarcodeCallback
import com.journeyapps.barcodescanner.BarcodeResult
import com.journeyapps.barcodescanner.BarcodeView
import com.journeyapps.barcodescanner.DefaultDecoderFactory

class ScanView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) : FrameLayout(context, attrs, defStyleAttr), BarcodeCallback {

    class Delegate {
        var didRequestPermission: (() -> Unit)? = null
        var didScanShard: ((instance: String, revision: String) -> Unit)? = null
    }

    private val barcode: BarcodeView
    private val requestPermission: Button

    val delegate = Delegate()

    init {
        View.inflate(context, R.layout.view_scan, this)

        barcode = this.findViewById(R.id.barcode)
        barcode.decoderFactory = DefaultDecoderFactory(
                listOf(BarcodeFormat.QR_CODE),
                null,
                null,
                1)
        barcode.decodeContinuous(this)

        requestPermission = findViewById(R.id.request_permission)
        requestPermission.setOnClickListener(::onRequestPermission)
    }

    private fun onRequestPermission(v: View) {
        delegate.didRequestPermission?.invoke()
    }

    fun setHasPermission(hasPermission: Boolean) {
        requestPermission.visibility = if (hasPermission) View.GONE else View.VISIBLE
    }

    override fun barcodeResult(result: BarcodeResult?) {
        val parts = result!!.text.split("/")
        delegate.didScanShard?.invoke(parts[0], parts[1])
    }

    override fun possibleResultPoints(resultPoints: MutableList<ResultPoint>?) { }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        barcode.resume()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        barcode.pause()
    }
}