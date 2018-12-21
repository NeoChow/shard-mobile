package app.visly


import java.util.HashMap

import android.content.res.AssetManager
import android.graphics.Typeface
import android.util.SparseArray

class VMLFontManager private constructor() {

    private val mFontCache: MutableMap<String, FontFamily> = HashMap()

    fun getTypeface(fontFamilyName: String, style: Int, assetManager: AssetManager): Typeface? {
        var fontFamily: FontFamily? = mFontCache[fontFamilyName]

        if (fontFamily == null) {
            fontFamily = FontFamily()
            mFontCache[fontFamilyName] = fontFamily
        }

        var typeface: Typeface? = fontFamily.getTypeface(style)
        if (typeface == null) {
            typeface = createTypeface(fontFamilyName, style, assetManager)
            fontFamily.setTypeface(style, typeface)
        }

        return typeface
    }

    /**
     * Add additional font family, or replace the exist one in the font memory cache.
     * @param style
     * @see {@link Typeface.DEFAULT}
     *
     * @see {@link Typeface.BOLD}
     *
     * @see {@link Typeface.ITALIC}
     *
     * @see {@link Typeface.BOLD_ITALIC}
     */
    fun setTypeface(fontFamilyName: String, style: Int, typeface: Typeface?) {
        if (typeface != null) {
            var fontFamily: FontFamily? = mFontCache[fontFamilyName]
            if (fontFamily == null) {
                fontFamily = FontFamily()
                mFontCache[fontFamilyName] = fontFamily
            }
            fontFamily.setTypeface(style, typeface)
        }
    }

    private class FontFamily {

        private val mTypefaceSparseArray: SparseArray<Typeface>

        init {
            mTypefaceSparseArray = SparseArray(4)
        }

        fun getTypeface(style: Int): Typeface? {
            return mTypefaceSparseArray.get(style)
        }

        fun setTypeface(style: Int, typeface: Typeface) {
            mTypefaceSparseArray.put(style, typeface)
        }

    }

    companion object {

        private val EXTENSIONS = arrayOf("", "_bold", "_italic", "_bold_italic")
        private val FILE_EXTENSIONS = arrayOf(".ttf", ".otf")
        private val FONTS_ASSET_PATH = "fonts/"

        val instance: VMLFontManager by lazy { VMLFontManager() }

        private fun createTypeface(fontFamilyName: String, style: Int, assetManager: AssetManager): Typeface {
            val extension = EXTENSIONS[style]
            for (fileExtension in FILE_EXTENSIONS) {
                val fileName = StringBuilder()
                        .append(FONTS_ASSET_PATH)
                        .append(fontFamilyName)
                        .append(extension)
                        .append(fileExtension)
                        .toString()
                try {
                    return Typeface.createFromAsset(assetManager, fileName)
                } catch (e: RuntimeException) { }
            }

            return Typeface.create(fontFamilyName, style)
        }
    }
}