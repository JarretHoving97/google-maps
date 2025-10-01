package com.whoisup.app.stream

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.AnimationConstants
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.padding
import androidx.compose.material.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import com.whoisup.app.ExtendedStreamPlugin
import com.whoisup.app.R
import com.whoisup.app.SuperEntitlementStatus
import com.whoisup.app.components.AmiButton
import com.whoisup.app.components.AmiEmptyContent
import com.whoisup.app.components.AmiPinnedMessage
import com.whoisup.app.stream.extensions.AmiParticipantRole
import com.whoisup.app.stream.extensions.ChatChannelRelatedConceptType
import com.whoisup.app.stream.extensions.amiParticipantRole
import com.whoisup.app.stream.extensions.isDirectMessageChannel
import com.whoisup.app.stream.extensions.isSupportTeamMember
import com.whoisup.app.stream.extensions.relatedConceptType
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.ui.components.SimpleDialog
import io.getstream.chat.android.compose.viewmodel.messages.AttachmentsPickerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessagesViewModelFactory
import io.getstream.chat.android.models.ChannelCapabilities
import io.getstream.chat.android.ui.common.state.messages.Delete
import java.time.ZoneId
import java.time.ZonedDateTime

class PinnedMessageViewModel : ViewModel() {
    var isModalOpened by mutableStateOf(false)
        private set

    fun openModal() {
        isModalOpened = true
    }

    fun closeModal() {
        isModalOpened = false
    }
}

class SafetyCheckViewModel : ViewModel() {
    var isModalOpened by mutableStateOf(false)
        private set

    fun openModal() {
        isModalOpened = true
    }

    fun closeModal() {
        isModalOpened = false
    }

    var isInfoModalOpened by mutableStateOf(false)
        private set

    fun openInfoModal() {
        isInfoModalOpened = true
    }

    fun closeInfoModal() {
        isInfoModalOpened = false
    }
}

enum class SafetyCheckState(val value: String) {
    Unanswered("UNANSWERED"),
    Positive("POSITIVE"),
    Negative("NEGATIVE"),
}

const val SAFETY_CHECK_STATE_KEY = "safetyCheckState"

@Composable
fun AmiChannelScreen(
    viewModelFactory: MessagesViewModelFactory,
    onBackClick: () -> Unit,
    onUserAvatarClick: (String) -> Unit,
    onWalkthroughClick: (slideKey: String?) -> Unit,
    onBecomeSuperClick: () -> Unit,
    onContactSupportClick: () -> Unit,
) {
    val listViewModel = viewModel(MessageListViewModel::class.java, factory = viewModelFactory)
    val composerViewModel = viewModel(MessageComposerViewModel::class.java, factory = viewModelFactory)
    val attachmentsPickerViewModel = viewModel(AttachmentsPickerViewModel::class.java, factory = viewModelFactory)

    val pinnedMessageViewModel = viewModel(PinnedMessageViewModel::class.java)
    val safetyCheckViewModel = viewModel(SafetyCheckViewModel::class.java)
    val singleChannelViewModel = viewModel(SingleChannelViewModel::class.java)

    val isImeVisible = WindowInsets.ime.getBottom(LocalDensity.current) > 0
    val backAction = remember(listViewModel, composerViewModel, attachmentsPickerViewModel) {
        {
            when {
                isImeVisible -> Unit

                attachmentsPickerViewModel.isShowingAttachments -> attachmentsPickerViewModel.changeAttachmentState(
                    false,
                )

                listViewModel.isShowingOverlay -> listViewModel.selectMessage(null)

                else -> onBackClick()
            }
        }
    }

    val currentUser by listViewModel.user.collectAsState()

    val otherUser = if (listViewModel.channel.isDirectMessageChannel()) {
        listViewModel.channel.members.firstOrNull {
            it.user.id != currentUser?.id
        }?.user
    } else {
        null
    }

    Box(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(CustomTheme.colorScheme.background)
        ) {
            BackHandler(enabled = true, onBack = backAction)

            AmiChannelHeader(listViewModel = listViewModel, singleChannelViewModel = singleChannelViewModel, onBackClick = backAction)

            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                val currentState = listViewModel.currentMessagesState

                var extraContentPaddingTop = 0.dp

                val myMember = listViewModel.channel.membership

                val isAllowedToUpdatePinnedMessage = when (listViewModel.channel.relatedConceptType) {
                    is ChatChannelRelatedConceptType.Standard -> {
                        false
                    }

                     is ChatChannelRelatedConceptType.Community -> {
                         myMember?.amiParticipantRole == AmiParticipantRole.CommunityOrganizer ||
                             myMember?.amiParticipantRole == AmiParticipantRole.CommunityPseudoOrganizer
                     }

                    else -> {
                        myMember?.amiParticipantRole == AmiParticipantRole.Organizer ||
                            myMember?.amiParticipantRole == AmiParticipantRole.PseudoOrganizer
                    }
                }

                val pinnedMessage = listViewModel.channel.extraData["pinnedMessage"] as? String

                val showPinnedMessage = (isAllowedToUpdatePinnedMessage && listViewModel.channel.relatedConceptType !is ChatChannelRelatedConceptType.Community) || !pinnedMessage.isNullOrBlank()

                if (showPinnedMessage) {
                    extraContentPaddingTop += 100.dp
                }

                val safetyCheckState = listViewModel.channel.extraData[SAFETY_CHECK_STATE_KEY] as? String

                val createdByMe = listViewModel.channel.createdBy.id == currentUser?.id

                val showSafetyCheck =
                    // Only show safety check for direct message channels.
                    otherUser != null &&
                    // You are not allowed to add a safety check if the other user is part of our support team.
                    !otherUser.isSupportTeamMember &&
                    // If you're the organizer, statistics say you're the sender
                    // of the first message ~99,7% of the time.
                    // And we do not allow the sender of the first message
                    // to review the other user.
                    !createdByMe &&
                    // No safety check should have been added yet.
                    safetyCheckState == SafetyCheckState.Unanswered.value

                if (showSafetyCheck) {
                    extraContentPaddingTop += 75.dp
                }

                val createdAt = listViewModel.channel.createdAt?.let {
                    ZonedDateTime.ofInstant(it.toInstant(), ZoneId.systemDefault())
                }

                val then = ZonedDateTime.parse("2024-04-25T00:00:00.000Z")

                val showSuperPowerOnlyNotice =
                    otherUser != null &&
                    ExtendedStreamPlugin.shared?.superEntitlementStatus == SuperEntitlementStatus.Available &&
                    createdAt?.isAfter(then) == true

                if (showSuperPowerOnlyNotice) {
                    extraContentPaddingTop += 75.dp
                }

                val showCommunityChatNotice = listViewModel.channel.relatedConceptType is ChatChannelRelatedConceptType.Community

                if (showCommunityChatNotice) {
                    extraContentPaddingTop += 75.dp
                }

                when {
                    currentState.isLoading -> {
                        CircularProgressIndicator(
                            modifier = Modifier.align(Alignment.Center),
                            color = CustomTheme.colorScheme.primary,
                            strokeWidth = 2.dp
                        )
                    }

                    currentState.messageItems.isNotEmpty() -> AmiChannelMessages(
                        listViewModel = listViewModel,
                        composerViewModel = composerViewModel,
                        extraContentPaddingTop = extraContentPaddingTop,
                        onUserAvatarClick = onUserAvatarClick,
                        onWalkthroughClick = onWalkthroughClick
                    )

                    else -> {
                        if (listViewModel.channel.isDirectMessageChannel()) {
                            Box(modifier = Modifier
                                .align(Alignment.Center)
                                .clickable(onClick = { safetyCheckViewModel.openInfoModal() })
                            ) {
                                AmiEmptyContent(
                                    text = stringResource(R.string.AmiChannelScreen_emptyState_safetyCheck),
                                    iconId = R.drawable.safety_shield_check_filled
                                )
                            }
                        } else {
                            AmiEmptyContent(
                                text = stringResource(R.string.AmiChannelScreen_emptyState_group),
                                iconId = io.getstream.chat.android.compose.R.drawable.stream_compose_empty_channels
                            )
                        }
                    }
                }

                Column(
                    modifier = Modifier.padding(vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    if (showPinnedMessage) {
                        AmiPinnedMessage(
                            text = pinnedMessage,
                            isAllowedToUpdatePinnedMessage = isAllowedToUpdatePinnedMessage,
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 12.dp),
                            onClick = {
                                pinnedMessageViewModel.openModal()
                            }
                        )
                    }

                    if (otherUser != null && showSafetyCheck) {
                        AmiSafetyCheckChatNotice(
                            safetyCheckViewModel = safetyCheckViewModel,
                            otherUser = otherUser,
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 12.dp),
                        )
                    }

                    if (showSuperPowerOnlyNotice) {
                        AmiChatSuperPowerOnlyNotice(
                            onBecomeSuperClick = onBecomeSuperClick,
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 12.dp),
                        )
                    }

                    if (showCommunityChatNotice) {
                        AmiChatCommunityAdminOnlyNotice(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 12.dp)
                        )
                    }
                }
            }

            val messageComposerState by composerViewModel.messageComposerState.collectAsState()
            val canSendMessage = messageComposerState.ownCapabilities.contains(ChannelCapabilities.SEND_MESSAGE)

            if (otherUser?.isSupportTeamMember == true) {
                // You are not allowed to chat if the other user is part of our support team.
                Box(
                    modifier = Modifier
                        .height(2.dp)
                        .fillMaxWidth()
                        .background(CustomTheme.colorScheme.surfaceHard)
                )

                AmiButton(
                    text = stringResource(id = R.string.global_contact),
                    onClick = onContactSupportClick,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(8.dp)
                )
            } else if (!canSendMessage && listViewModel.channel.relatedConceptType is ChatChannelRelatedConceptType.Community) {
                // In this case we want to hide the composer entirely
            } else {
                AmiChannelComposer(
                    listViewModel = listViewModel,
                    composerViewModel = composerViewModel,
                    attachmentsPickerViewModel = attachmentsPickerViewModel,
                )
            }
        }

        val selectedMessageState = listViewModel.currentMessagesState.selectedMessageState

        AmiChannelMenu(
            singleChannelViewModel = singleChannelViewModel,
            currentUser = currentUser,
            onBackClick = onBackClick,
        )

        AmiPinnedMessageMenu(
            listViewModel = listViewModel,
            pinnedMessageViewModel = pinnedMessageViewModel,
        )

        if (otherUser != null) {
            AmiSafetyCheckReviewModal(
                otherUser = otherUser,
                safetyCheckViewModel = safetyCheckViewModel,
            )

            val createdByMe = listViewModel.channel.createdBy.id == currentUser?.id
            AmiSafetyCheckInfoModal(
                safetyCheckViewModel = safetyCheckViewModel,
                receiverName = otherUser.name,
                variant = if (createdByMe) {
                    AmiSafetyCheckInfoModalVariant.Receiver
                } else {
                    AmiSafetyCheckInfoModalVariant.Sender
                }
            )
        }

        AmiMessageMenu(
            listViewModel = listViewModel,
            composerViewModel = composerViewModel,
            selectedMessageState = selectedMessageState,
            currentUser = currentUser,
        )

        AmiReactionsMenu(
            listViewModel = listViewModel,
            selectedMessageState = selectedMessageState,
        )

        AttachmentsPickerMenu(
            listViewModel = listViewModel,
            attachmentsPickerViewModel = attachmentsPickerViewModel,
            composerViewModel = composerViewModel,
        )

        MessageDialogs(listViewModel = listViewModel)

        // We don't need the following component,
        // because we do not have more than 5 reactions anyways
        // MessagesScreenReactionsPicker
    }
}

/**
 * Contains the attachments picker menu wrapped inside
 * of an animated composable.
 *
 * @param attachmentsPickerViewModel The [AttachmentsPickerViewModel] used to read state and
 * perform actions.
 * @param composerViewModel The [MessageComposerViewModel] used to read state and
 * perform actions.
 */
@Composable
private fun AttachmentsPickerMenu(
    listViewModel: MessageListViewModel,
    attachmentsPickerViewModel: AttachmentsPickerViewModel,
    composerViewModel: MessageComposerViewModel,
) {
    val isShowingAttachments = attachmentsPickerViewModel.isShowingAttachments

    AnimatedVisibility(
        visible = isShowingAttachments,
        enter = fadeIn(),
        exit = fadeOut(animationSpec = tween(delayMillis = AnimationConstants.DefaultDurationMillis / 2)),
    ) {
        AmiAttachmentsPicker(
            listViewModel = listViewModel,
            attachmentsPickerViewModel = attachmentsPickerViewModel,
            composerViewModel = composerViewModel
        )
    }
}

/**
 * Contains the message dialogs used to prompt the
 * user with message flagging and deletion actions
 *
 * @param listViewModel The [MessageListViewModel] used to read state and
 * perform actions.
 */
@Composable
private fun MessageDialogs(listViewModel: MessageListViewModel) {
    val messageActions = listViewModel.messageActions

    val deleteAction = messageActions.firstOrNull { it is Delete }

    if (deleteAction != null) {
        SimpleDialog(
            modifier = Modifier.padding(16.dp),
            title = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_delete_message_title),
            message = stringResource(id = io.getstream.chat.android.compose.R.string.stream_compose_delete_message_text),
            onPositiveAction = remember(listViewModel) { { listViewModel.deleteMessage(deleteAction.message) } },
            onDismiss = remember(listViewModel) { { listViewModel.dismissMessageAction(deleteAction) } },
        )
    }
}