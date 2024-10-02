package com.whoisup.app.stream

import android.os.Build
import androidx.annotation.DrawableRes
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.ImageLoader
import coil.compose.rememberAsyncImagePainter
import coil.decode.GifDecoder
import coil.decode.ImageDecoderDecoder
import coil.request.ImageRequest
import coil.size.Size

@Composable
fun AmiMessageWalkthrough(@DrawableRes gifId: Int) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFF_8833CB))
            .padding(16.dp)
            .height(112.dp),
        contentAlignment = Alignment.Center
    ) {
        val context = LocalContext.current
        val imageLoader = ImageLoader.Builder(context)
            .components {
                if (Build.VERSION.SDK_INT >= 28) {
                    add(ImageDecoderDecoder.Factory())
                } else {
                    add(GifDecoder.Factory())
                }
            }
            .build()

        Image(
            painter = rememberAsyncImagePainter(
                ImageRequest.Builder(context).data(data = gifId)
                    .apply(block = {
                        size(Size.ORIGINAL)
                    }).build(),
                imageLoader = imageLoader
            ),
            contentDescription = null,
            modifier = Modifier.fillMaxHeight()
        )
    }
}