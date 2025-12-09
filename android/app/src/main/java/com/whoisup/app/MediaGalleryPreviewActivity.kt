package com.whoisup.app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.MediaController
import android.widget.VideoView
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.rememberScaffoldState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.viewinterop.AndroidView
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.whoisup.app.components.AmiHeader
import com.whoisup.app.stream.MediaGalleryPreviewActivityState
import com.whoisup.app.stream.PlayButton
import com.whoisup.app.stream.toMediaGalleryPreviewActivityState
import com.whoisup.app.ui.theme.CustomTheme
import com.whoisup.app.utils.enableEdgeToEdgeCustom
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.client.utils.attachment.isImage
import io.getstream.chat.android.client.utils.attachment.isVideo
import io.getstream.chat.android.client.utils.message.isDeleted
import io.getstream.chat.android.compose.ui.components.LoadingIndicator
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.ui.util.LocalStreamImageLoader
import io.getstream.chat.android.compose.viewmodel.mediapreview.MediaGalleryPreviewViewModel
import io.getstream.chat.android.compose.viewmodel.mediapreview.MediaGalleryPreviewViewModelFactory
import io.getstream.chat.android.core.internal.InternalStreamChatApi
import io.getstream.chat.android.models.Attachment
import io.getstream.chat.android.models.Message
import io.getstream.chat.android.ui.common.utils.StreamFileUtil
import io.getstream.chat.android.ui.common.utils.extensions.imagePreviewUrl
import kotlinx.coroutines.launch
import net.engawapg.lib.zoomable.rememberZoomState
import net.engawapg.lib.zoomable.zoomable

class MediaGalleryPreviewActivity : AppCompatActivity() {

    /**
     * Factory used to build the screen ViewModel given the received message ID.
     */
    private val factory by lazy {
        val messageId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent?.getParcelableExtra(
                KeyMediaGalleryPreviewActivityState, MediaGalleryPreviewActivityState::class.java,
            )?.messageId
        } else {
            intent?.getParcelableExtra<MediaGalleryPreviewActivityState>(
                KeyMediaGalleryPreviewActivityState,
            )?.messageId
        } ?: ""

        MediaGalleryPreviewViewModelFactory(
            chatClient = ChatClient.instance(),
            messageId = messageId,
            skipEnrichUrl = false
        )
    }

    /**
     * The ViewModel that exposes screen data.
     */
    private val mediaGalleryPreviewViewModel by viewModels<MediaGalleryPreviewViewModel>(factoryProducer = { factory })

    /**
     * Sets up the data required to show the previews of images or videos within the given message.
     *
     * Immediately finishes in case the data is invalid.
     */
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        enableEdgeToEdgeCustom()

        val mediaGalleryPreviewActivityState = intent?.getParcelableExtra<MediaGalleryPreviewActivityState>(
            KeyMediaGalleryPreviewActivityState,
        )

        // @TODO(1): check if we need to incorporate this fix: https://github.com/GetStream/stream-chat-android/issues/5148
        val messageId = mediaGalleryPreviewActivityState?.messageId ?: ""

//        if (!mediaGalleryPreviewViewModel.hasCompleteMessage) {
//            val message = mediaGalleryPreviewActivityState?.toMessage()
//
//            if (message != null) {
//                mediaGalleryPreviewViewModel.message = message
//            }
//        }

        val attachmentPosition = intent?.getIntExtra(KeyAttachmentPosition, 0) ?: 0

        if (messageId.isBlank()) {
            throw IllegalArgumentException("Missing messageId necessary to load images.")
        }

        setContent {
            CustomTheme {
                val message = mediaGalleryPreviewViewModel.message

                if (message.isDeleted()) {
                    finish()
                    return@CustomTheme
                }

                Box(modifier = Modifier.safeDrawingPadding().fillMaxSize()) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(CustomTheme.colorScheme.background)
                    ) {
                        AmiHeader(onBackClick = { finish() })

                        val filteredAttachments = message.attachments.filter {
                            it.isImage() || it.isVideo()
                        }

                        if (filteredAttachments.isNotEmpty()) {
                            MediaGalleryPreviewContentWrapper(filteredAttachments, message, attachmentPosition)
                        }
                    }
                }
            }
        }
    }

    @OptIn(ExperimentalFoundationApi::class)
    @Composable
    private fun MediaGalleryPreviewContentWrapper(
        attachments: List<Attachment>,
        message: Message,
        initialAttachmentPosition: Int,
    ) {
        val startingPosition =
            if (initialAttachmentPosition !in attachments.indices) 0 else initialAttachmentPosition

        val scaffoldState = rememberScaffoldState()
        val pagerState = rememberPagerState(
            initialPage = startingPosition,
            pageCount = { attachments.size })
        val coroutineScope = rememberCoroutineScope()

        if (message.id.isNotEmpty()) {
            MediaPreviewContent(pagerState, attachments) {
                coroutineScope.launch {
                    scaffoldState.snackbarHostState.showSnackbar(
                        message = getString(io.getstream.chat.android.compose.R.string.stream_ui_message_list_video_display_error),
                    )
                }
            }
        }
    }

    /**
     * Renders a horizontal pager that shows images and allows the user to swipe, zoom and pan through them.
     *
     * @param pagerState The state of the content pager.
     * @param attachments The attachments to show within the pager.
     */
    @OptIn(ExperimentalFoundationApi::class)
    @Suppress("LongMethod", "ComplexMethod")
    @Composable
    private fun MediaPreviewContent(
        pagerState: PagerState,
        attachments: List<Attachment>,
        onPlaybackError: () -> Unit,
    ) {
        if (attachments.isEmpty()) {
            finish()
            return
        }

        HorizontalPager(
            modifier = Modifier.background(CustomTheme.colorScheme.background),
            state = pagerState,
            beyondViewportPageCount = 2
        ) { page ->
            if (attachments[page].isImage()) {
                ImagePreviewContent(attachment = attachments[page])
            } else if (attachments[page].isVideo()) {
                VideoPreviewContent(
                    attachment = attachments[page],
                    pagerState = pagerState,
                    page = page,
                    onPlaybackError = onPlaybackError,
                )
            }
        }
    }

    /**
     * Represents an individual page containing an image that is zoomable and scrollable.
     *
     * @param attachment The image attachment to be displayed.
     * @param pagerState The state of the pager that contains this page
     * @param page The page an instance of this content is located on.
     */
    @Composable
    private fun ImagePreviewContent(
        attachment: Attachment,
    ) {
        val data = attachment.imagePreviewUrl
        val context = LocalContext.current

        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center,
        ) {
            // @TODO: we could use `SubcomposeAsyncImage` to provide composables to the loading and error states
            AsyncImage(
                model = remember {
                    ImageRequest.Builder(context)
                        .data(data)
                        .crossfade(true)
                        .build()
                },
                contentDescription = null,
                imageLoader = LocalStreamImageLoader.current,
                modifier = Modifier.zoomable(rememberZoomState()),
                error = painterResource(
                    id = io.getstream.chat.android.compose.R.drawable.stream_compose_ic_image_picker,
                ),
            )
        }
    }

    /**
     * Represents an individual page containing video player with media controls.
     *
     * @param attachment The video attachment to be played.
     * @param pagerState The state of the pager that contains this page
     * @param page The page an instance of this content is located on.
     * @param onPlaybackError Handler for playback errors.
     */
    @OptIn(ExperimentalFoundationApi::class)
    @Composable
    private fun VideoPreviewContent(
        attachment: Attachment,
        pagerState: PagerState,
        page: Int,
        onPlaybackError: () -> Unit,
    ) {
        val context = LocalContext.current

        var hasPrepared by remember {
            mutableStateOf(false)
        }

        var userHasClickedPlay by remember {
            mutableStateOf(false)
        }

        var shouldShowProgressBar by remember {
            mutableStateOf(false)
        }

        var shouldShowPreview by remember {
            mutableStateOf(true)
        }

        var shouldShowPlayButton by remember {
            mutableStateOf(true)
        }

        val mediaController = remember {
            createMediaController(context)
        }

        val videoView = remember {
            VideoView(context)
        }

        val contentView = remember {
            val frameLayout = FrameLayout(context).apply {
                layoutParams = FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                )
            }
            videoView.apply {
                setVideoURI(Uri.parse(attachment.assetUrl))
                this.setMediaController(mediaController)
                setOnErrorListener { _, _, _ ->
                    shouldShowProgressBar = false
                    onPlaybackError()
                    true
                }
                setOnPreparedListener {
                    // Don't remove the preview unless the user has clicked play previously,
                    // otherwise the preview will be removed whenever the video has finished downloading.
                    if (!hasPrepared && userHasClickedPlay && page == pagerState.currentPage) {
                        shouldShowProgressBar = false
                        shouldShowPreview = false
                        mediaController.show()
                    }
                    hasPrepared = true
                }

                mediaController.setAnchorView(frameLayout)

                layoutParams = FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                ).apply {
                    gravity = Gravity.CENTER
                }
            }

            frameLayout.apply {
                addView(videoView)
            }
        }

        Box(contentAlignment = Alignment.Center) {
            AndroidView(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color.Black),
                factory = { contentView },
            )

            if (shouldShowPreview) {
                val data = if (ChatTheme.videoThumbnailsEnabled) {
                    attachment.thumbUrl
                } else {
                    null
                }

                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier.fillMaxSize(),
                ) {
                    // StreamImage
                    AsyncImage(
                        modifier = Modifier
                            .clickable {
                                shouldShowProgressBar = true
                                shouldShowPlayButton = false
                                userHasClickedPlay = true
                                // Don't remove the preview unless the player
                                // is ready to play.
                                if (hasPrepared) {
                                    shouldShowProgressBar = false
                                    shouldShowPreview = false
                                    mediaController.show()
                                }
                                videoView.start()
                            }
                            .fillMaxSize()
                            .background(color = Color.Black),
                        model =
                            ImageRequest.Builder(LocalContext.current)
                                .data(data)
                                .build(),
                        contentDescription = null,
                        imageLoader = LocalStreamImageLoader.current
                    )

                    if (shouldShowPlayButton) {
                        PlayButton()
                    }
                }
            }

            if (shouldShowProgressBar) {
                LoadingIndicator()
            }
        }

        if (page != pagerState.currentPage) {
            shouldShowPlayButton = true
            shouldShowPreview = true
            shouldShowProgressBar = false
            mediaController.hide()
        }
    }

    /**
     * Creates a custom instance of [MediaController].
     *
     * @param context The Context used to create the [MediaController].
     */
    private fun createMediaController(
        context: Context,
    ): MediaController {
        return object : MediaController(context) {}
    }

    @OptIn(InternalStreamChatApi::class)
    override fun onDestroy() {
        super.onDestroy()
        StreamFileUtil.clearStreamCache(context = applicationContext)
    }

    companion object {
        /**
         * Represents the key for the ID of the message with the attachments we're browsing.
         */
        private const val KeyMediaGalleryPreviewActivityState: String = "mediaGalleryPreviewActivityState"

        /**
         * Represents the key for the starting attachment position based on the clicked attachment.
         */
        private const val KeyAttachmentPosition: String = "attachmentPosition"

        /**
         * Represents the key for the result of the preview, like scrolling to the message.
         */
        const val KeyMediaGalleryPreviewResult: String = "mediaGalleryPreviewResult"

        /**
         * Used to build an [Intent] to start the [MediaGalleryPreviewActivity] with the required data.
         *
         * @param context The context to start the activity with.
         * @param message The [Message] containing the attachments.
         * @param attachmentPosition The initial position of the clicked media attachment.
         */
        fun getIntent(
            context: Context,
            message: Message,
            attachmentPosition: Int,
        ): Intent {
            return Intent(context, MediaGalleryPreviewActivity::class.java).apply {
                val mediaGalleryPreviewActivityState = message.toMediaGalleryPreviewActivityState()

                putExtra(KeyMediaGalleryPreviewActivityState, mediaGalleryPreviewActivityState)
                putExtra(KeyAttachmentPosition, attachmentPosition)
            }
        }
    }
}
