package com.whoisup.app.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import coil3.compose.AsyncImagePainter
import coil3.request.ImageRequest
import com.whoisup.app.ui.theme.CustomTheme

data class UserForAmiAvatar(
    val id: String?,
    val name: String?,
    val avatarUrl: String?,
)

@Composable
fun AmiAvatar(
    user: UserForAmiAvatar,
    modifier: Modifier = Modifier,
    size: Dp = 40.dp,
    borderWidth: Dp = 0.dp,
    borderColor: Color = Color.Unspecified,
    blur: Boolean = false,
    onClick: (() -> Unit)? = null
) {
    var imageRequestState by remember { mutableStateOf<AsyncImagePainter.State?>(null) }

    Box(modifier = modifier.size(size)) {
        Box(
            modifier =
            Modifier.fillMaxSize()
                .border(borderWidth, borderColor, CircleShape)
                .padding(borderWidth)
                .clip(CircleShape)
                .then(if (onClick != null) {
                    Modifier.clickable(
                        onClick = {
                            onClick()
                        }
                    )
                } else {
                    Modifier
                })
                .background(CustomTheme.colorScheme.surface),
            contentAlignment = Alignment.Center
        ) {
            user.name
                ?.ifBlank { null }
                ?.let {
                    BasicText(
                        text = "${it.toCharArray()[0]}.",
                        style =
                        CustomTheme.typography.subhead.copy(
                            color = CustomTheme.colorScheme.onSurface,
                        )
                    )
                }
            if (user.avatarUrl !== null) {
                AsyncImage(
                    model = ImageRequest.Builder(LocalContext.current).data(user.avatarUrl).build(),
                    contentDescription = null,
                    modifier =
                    Modifier.fillMaxSize()
                        .blur(
                            if (blur) {
                                4.dp
                            } else {
                                0.dp
                            }
                        )
                        .background(
                            if (imageRequestState is AsyncImagePainter.State.Success) {
                                CustomTheme.colorScheme.surface
                            } else {
                                // If image is not shown,
                                // the content behind the image should be visible
                                Color.Transparent
                            }
                        ),
                    onState = { imageRequestState = it },
                    contentScale = ContentScale.Crop,
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun AmiAvatarPreview() {
    CustomTheme {
        LazyColumn(
            modifier =
            Modifier.fillMaxSize().background(CustomTheme.colorScheme.background).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            val avatarUrl =
                "https://profilepictures-dev.amigosapp.nl/public/720x720/7328222c-f0ac-4922-b2a5-75d4924ac0de.jpg"
            val user = UserForAmiAvatar("1", "John Doe", avatarUrl)

            item { AmiAvatar(user) }
            item {
                AmiAvatar(user, borderWidth = 2.dp, borderColor = CustomTheme.colorScheme.surfaceHard)
            }
            item { AmiAvatar(user, borderWidth = 2.dp, borderColor = CustomTheme.colorScheme.primary) }
        }
    }
}
