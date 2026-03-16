package com.whoisup.app.stream

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.material.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
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
import com.whoisup.app.components.AmiEmptyContent
import com.whoisup.app.components.AmiPinnedMessage
import com.whoisup.app.stream.extensions.AmiParticipantRole
import com.whoisup.app.stream.extensions.ChatChannelRelatedConceptType
import com.whoisup.app.stream.extensions.amiParticipantRole
import com.whoisup.app.stream.extensions.isDirectMessageChannel
import com.whoisup.app.stream.extensions.isSupportTeamMember
import com.whoisup.app.stream.extensions.relatedConceptType
import com.whoisup.app.stream.viewModels.MessageSuggestionsViewModel
import com.whoisup.app.stream.viewModels.MessageSuggestionsViewModelFactory
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.compose.viewmodel.messages.AttachmentsPickerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessagesViewModelFactory
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

    val activityStartsAt = remember(listViewModel.channel.extraData["activityStartsAt"]) {
        mutableStateOf(listViewModel.channel.extraData["activityStartsAt"] as? String)
    }

    val pinnedMessageViewModel = viewModel(PinnedMessageViewModel::class.java)
    val safetyCheckViewModel = viewModel(SafetyCheckViewModel::class.java)
    val singleChannelViewModel = viewModel(SingleChannelViewModel::class.java)
    val messageSuggestionsViewModel = viewModel(MessageSuggestionsViewModel::class.java, factory = MessageSuggestionsViewModelFactory(
            listViewModel,
            composerViewModel
        )
    )

    LaunchedEffect(activityStartsAt) {
        // Explicitly recalculate values in viewmodel to ensure reactiveness.
        // There would probably be a better (more common) way to do this.
        // But this is fine for now
        messageSuggestionsViewModel.calculate()
    }

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

    Box(modifier = Modifier.safeDrawingPadding().fillMaxSize()) {
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

                var contentPaddingTop = 16.dp

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
                    contentPaddingTop += 100.dp
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
                    contentPaddingTop += 75.dp
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
                    contentPaddingTop += 75.dp
                }

                val showCommunityChatNotice = listViewModel.channel.relatedConceptType is ChatChannelRelatedConceptType.Community

                if (showCommunityChatNotice) {
                    contentPaddingTop += 75.dp
                }

                when {
                    currentState.value.isLoading -> {
                        CircularProgressIndicator(
                            modifier = Modifier.align(Alignment.Center),
                            color = CustomTheme.colorScheme.primary,
                            strokeWidth = 2.dp
                        )
                    }

                    currentState.value.messageItems.isNotEmpty() -> AmiChannelMessages(
                        listViewModel = listViewModel,
                        composerViewModel = composerViewModel,
                        messageSuggestionsViewModel = messageSuggestionsViewModel,
                        contentPaddingTop = contentPaddingTop,
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

            AmiChannelComposerContainer(
                listViewModel = listViewModel,
                composerViewModel = composerViewModel,
                attachmentsPickerViewModel = attachmentsPickerViewModel,
                onContactSupportClick = onContactSupportClick
            )
        }

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

        AmiChannelMenus(
            listViewModel = listViewModel,
            attachmentsPickerViewModel = attachmentsPickerViewModel,
            composerViewModel = composerViewModel,
        )
    }
}