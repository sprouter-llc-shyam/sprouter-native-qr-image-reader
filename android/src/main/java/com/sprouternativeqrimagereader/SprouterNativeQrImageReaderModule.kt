package com.sprouternativeqrimagereader

import android.graphics.BitmapFactory
import android.util.Base64
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage

@ReactModule(name = sprouternativeqrimagereaderModule.NAME)
class sprouternativeqrimagereaderModule : NativesprouternativeqrimagereaderSpec() {
  companion object {
    const val NAME = "sprouternativeqrimagereader"
  }

  override fun readQRFromImage(source: String, promise: Promise) {
    try {
      val bitmap = loadBitmap(source)
      val image = InputImage.fromBitmap(bitmap, 0)

      val scanner = BarcodeScanning.getClient()
      scanner.process(image)
              .addOnSuccessListener { barcodes ->
                val results = barcodes.mapNotNull { it.rawValue }
                promise.resolve(results)
              }
              .addOnFailureListener { promise.reject("scan_error", it) }
    } catch (e: Exception) {
      promise.reject("load_error", e)
    }
  }

  private fun loadBitmap(source: String): Bitmap {
    return if (source.startsWith("data:image")) {
      val base64 = source.substringAfter(",")
      val bytes = Base64.decode(base64, Base64.DEFAULT)
      BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
    } else {
      BitmapFactory.decodeFile(source)
    }
  }
}
