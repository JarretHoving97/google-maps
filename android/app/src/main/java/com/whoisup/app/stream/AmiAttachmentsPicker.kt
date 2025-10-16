package com.whoisup.app.stream

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibilityScope
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.core.AnimationConstants
import androidx.compose.animation.core.tween
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.material.Card
import androidx.compose.material.Icon
import androidx.compose.material.IconButton
import androidx.compose.material.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.MAX_OPTIONS
import com.whoisup.app.components.DcIcon
import com.whoisup.app.stream.extensions.isDirectMessageChannel
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.R
import io.getstream.chat.android.compose.state.messages.attachments.AttachmentsPickerMode
import io.getstream.chat.android.compose.state.messages.attachments.Files
import io.getstream.chat.android.compose.state.messages.attachments.Images
import io.getstream.chat.android.compose.state.messages.attachments.MediaCapture
import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentPickerBack
import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentPickerPollCreation
import io.getstream.chat.android.compose.ui.messages.attachments.factory.AttachmentsPickerTabFactory
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.ui.util.mirrorRtl
import io.getstream.chat.android.compose.viewmodel.messages.AttachmentsPickerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.models.Attachment
import io.getstream.chat.android.models.Channel
import io.getstream.chat.android.models.PollConfig

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun AnimatedVisibilityScope.AmiAttachmentsPicker(
    listViewModel: MessageListViewModel,
    attachmentsPickerViewModel: AttachmentsPickerViewModel,
    composerViewModel: MessageComposerViewModel,
) {
    val tabFactories = ChatTheme.attachmentsPickerTabFactories

    val onAttachmentsSelected: (List<Attachment>) -> Unit = remember(attachmentsPickerViewModel) {
        {
            attachmentsPickerViewModel.changeAttachmentState(false)
            composerViewModel.addSelectedAttachments(it)
        }
    }

    val onDismiss = remember(attachmentsPickerViewModel) {
        {
            // Calling `changeAttachmentState` resets the `pickerMode` to `Images` for some reason.
            // So we reset it to the current `pickerMode` manually.
            // This is a workaround, until https://github.com/GetStream/stream-chat-android/pull/5614 gets merged
            val pickerMode = attachmentsPickerViewModel.attachmentsPickerMode
            attachmentsPickerViewModel.changeAttachmentState(false)
            attachmentsPickerViewModel.changeAttachmentPickerMode(pickerMode) { false }
        }
    }

    Box(
        modifier = Modifier
            .background(ChatTheme.attachmentPickerTheme.backgroundOverlay)
            .safeDrawingPadding()
            .fillMaxSize()
            .clickable(
                onClick = onDismiss,
                indication = null,
                interactionSource = remember { MutableInteractionSource() },
            ),
    ) {
        Card(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .height(ChatTheme.dimens.attachmentsPickerHeight)
                .animateEnterExit(
                    enter = slideInVertically(
                        initialOffsetY = { height -> height },
                        animationSpec = tween(),
                    ),
                    exit = slideOutVertically(
                        targetOffsetY = { height -> height },
                        animationSpec = tween(delayMillis = AnimationConstants.DefaultDurationMillis / 2),
                    ),
                )
                .clickable(
                    indication = null,
                    onClick = {},
                    interactionSource = remember { MutableInteractionSource() },
                ),
            elevation = 4.dp,
            shape = ChatTheme.shapes.bottomSheet,
            backgroundColor = ChatTheme.attachmentPickerTheme.backgroundSecondary,
        ) {
            Column {
                AttachmentPickerOptions(
                    hasPickedAttachments = attachmentsPickerViewModel.hasPickedAttachments,
                    tabFactories = tabFactories,
                    attachmentsPickerMode = attachmentsPickerViewModel.attachmentsPickerMode,
                    channel = attachmentsPickerViewModel.channel,
                    onTabClick = { attachmentPickerMode ->
                        attachmentsPickerViewModel.changeAttachmentPickerMode(attachmentPickerMode) { false }
                    },
                    onSendAttachmentsClick = {
                        onAttachmentsSelected(attachmentsPickerViewModel.getSelectedAttachments())
                    },
                )

                if (
                    !listViewModel.channel.isDirectMessageChannel() && (
                        attachmentsPickerViewModel.attachmentsPickerMode is Images ||
                        attachmentsPickerViewModel.attachmentsPickerMode is Files ||
                        attachmentsPickerViewModel.attachmentsPickerMode is MediaCapture
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(ChatTheme.attachmentPickerTheme.backgroundSecondary)
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        DcIcon(
                            id = com.whoisup.app.R.drawable.alert_circle,
                            contentDescription = null,
                            size = 16.dp,
                            color = CustomTheme.colorScheme.primary
                        )

                        BasicText(
                            text = stringResource(com.whoisup.app.R.string.AmiAttachmentsPicker_mediaUsedForStoriesConsent),
                            style = CustomTheme.typography.captionSmall.copy(color = CustomTheme.colorScheme.onSurface),
                            modifier = Modifier.weight(1f)
                        )
                    }
                }

                Surface(
                    modifier = Modifier.fillMaxSize(),
                    shape = ChatTheme.shapes.bottomSheet,
                    color = ChatTheme.attachmentPickerTheme.backgroundPrimary,
                ) {
                    AnimatedContent(targetState = attachmentsPickerViewModel.attachmentsPickerMode, label = "") { attachmentsPickerMode ->
                        tabFactories.firstOrNull { tabFactory ->
                            tabFactory.attachmentsPickerMode == attachmentsPickerMode
                        }
                        ?.PickerTabContent(
                            onAttachmentPickerAction = {
                                if (it is AttachmentPickerBack) {
                                    attachmentsPickerViewModel.changeAttachmentState(false)
                                }

                                if (it is AttachmentPickerPollCreation) {
                                    val multipleVotesAllowed = it.switches.any {
                                        switch -> switch.key == "multipleVotesAllowed" && switch.enabled
                                    }

                                    composerViewModel.createPoll(
                                        pollConfig = PollConfig(
                                            name = it.question,
                                            options = it.options.map { option -> option.title },
                                            maxVotesAllowed = if (multipleVotesAllowed) { MAX_OPTIONS } else { 1 },
                                            enforceUniqueVote = !multipleVotesAllowed,
                                        ),
                                    )

                                    attachmentsPickerViewModel.changeAttachmentState(false)
                                }
                            },
                            attachments = attachmentsPickerViewModel.attachments,
                            onAttachmentItemSelected = attachmentsPickerViewModel::changeSelectedAttachments,
                            onAttachmentsChanged = { attachmentsPickerViewModel.attachments = it },
                            onAttachmentsSubmitted = {
                                onAttachmentsSelected(attachmentsPickerViewModel.getAttachmentsFromMetaData(it))
                            },
                        )
                    }
                }
            }
        }
    }
}

/**
 * The options for the Attachment picker. Shows tabs based on the provided list of [tabFactories]
 * and a button to submit the selected attachments.
 *
 * @param hasPickedAttachments If we selected any attachments in the currently selected tab.
 * @param tabFactories The list of factories to build tab icons.
 * @param attachmentsPickerMode The tab that we selected.
 * @param channel The channel where the attachments picker is being used.
 * @param onTabClick Handler for clicking on any of the tabs, to change the shown attachments.
 * @param onSendAttachmentsClick Handler when confirming the picked attachments.
 */
@Suppress("LongParameterList")
@Composable
private fun AttachmentPickerOptions(
    hasPickedAttachments: Boolean,
    tabFactories: List<AttachmentsPickerTabFactory>,
    attachmentsPickerMode: AttachmentsPickerMode,
    channel: Channel,
    onTabClick: (AttachmentsPickerMode) -> Unit,
    onSendAttachmentsClick: () -> Unit,
) {
    Row(
        Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Row(horizontalArrangement = Arrangement.SpaceEvenly) {
            tabFactories.forEach { tabFactory ->
                val isSelected = attachmentsPickerMode == tabFactory.attachmentsPickerMode

                if (tabFactory.isPickerTabEnabled(channel)) {
                    val isEnabled = isSelected || !hasPickedAttachments
                    IconButton(
                        content = {
                            tabFactory.PickerTabIcon(
                                isEnabled = isEnabled,
                                isSelected = isSelected,
                            )
                        },
                        onClick = { onTabClick(tabFactory.attachmentsPickerMode) },
                    )
                }
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        IconButton(
            enabled = hasPickedAttachments,
            onClick = onSendAttachmentsClick,
            content = {
                val layoutDirection = LocalLayoutDirection.current

                Icon(
                    modifier = Modifier
                        .weight(1f)
                        .mirrorRtl(layoutDirection = layoutDirection),
                    painter = painterResource(id = R.drawable.stream_compose_ic_left),
                    contentDescription = stringResource(id = R.string.stream_compose_send_attachment),
                    tint = if (hasPickedAttachments) {
                        ChatTheme.colors.primaryAccent
                    } else {
                        ChatTheme.colors.textLowEmphasis
                    },
                )
            },
        )
    }
}
