package com.whoisup.app.stream.viewModels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.whoisup.app.R
import com.whoisup.app.stream.extensions.AmiParticipantRole
import com.whoisup.app.stream.extensions.ChatChannelRelatedConceptType
import com.whoisup.app.stream.extensions.amiParticipantRole
import com.whoisup.app.stream.extensions.relatedConceptType
import io.getstream.chat.android.compose.viewmodel.messages.MessageComposerViewModel
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel
import io.getstream.chat.android.ui.common.feature.messages.composer.capabilities.canSendMessage
import java.time.Duration
import java.time.ZoneId
import java.time.ZonedDateTime

private val hostReminderSuggestions48Hours = listOf(
    R.string.message_suggestion_planCTA,
    R.string.message_suggestion_whenFull,
    R.string.message_suggestion_whereFull,
    R.string.message_suggestion_whenShort,
    R.string.message_suggestion_timeFull,
)

private val hostReminderSuggestions9Hours = listOf(
    R.string.message_suggestion_funGroupAlready,
    R.string.message_suggestion_whoFirstTime,
    R.string.message_suggestion_excitedToMeet,
    R.string.message_suggestion_cantWaitShort,
    R.string.message_suggestion_firstTimeHosting,
)

private val hostReminderSuggestions3Hours = listOf(
    R.string.message_suggestion_arrivalTenBefore,
    R.string.message_suggestion_whenArrival,
    R.string.message_suggestion_waitingOutside,
    R.string.message_suggestion_whereMeet,
    R.string.message_suggestion_delayedRunningLate,
)

private val icebreakerSuggestions120Hours = listOf(
    R.string.message_suggestion_favoriteIntroDrink,
    R.string.message_suggestion_dilemmaAskerOrAnswerer,
    R.string.message_suggestion_dilemmaNeverAloneOrAlwaysAlone,
    R.string.message_suggestion_dilemmaPlannedOrSpontaneous,
    R.string.message_suggestion_twoTruthsOneLie,
)

class MessageSuggestionsViewModel(
    val listViewModel: MessageListViewModel,
    val composerViewModel: MessageComposerViewModel,
) : ViewModel() {
    var hostReminderSuggestions = listOf<Int>()
        private set

    var icebreakerSuggestions = listOf<Int>()
        private set

    fun calculate() {
        val myMember = listViewModel.channel.membership

        val relatedConceptTypeIsActivity = listViewModel.channel.relatedConceptType is ChatChannelRelatedConceptType.Activity

        val isAllowedToSelectSuggestions =
            // User must be able to send messages
            composerViewModel.messageComposerState.value.canSendMessage() &&
                    // suggestions are only shown for activity related chats
                    relatedConceptTypeIsActivity

        val isOrganizer = myMember?.amiParticipantRole == AmiParticipantRole.Organizer || myMember?.amiParticipantRole == AmiParticipantRole.PseudoOrganizer

        val activityStartsAt = listViewModel.channel.extraData["activityStartsAt"] as? String

        val diffInHours = run {
            if (activityStartsAt != null) {
                val zonedActivityStartsAt = try {
                    ZonedDateTime.parse(activityStartsAt)
                } catch (e: Exception) {
                    // Invalid date
                    null
                }

                if (zonedActivityStartsAt != null) {
                    val zonedNow = ZonedDateTime.now(ZoneId.systemDefault())

                    return@run Duration.between(zonedNow, zonedActivityStartsAt).toHours()
                }
            }

            null
        }

        hostReminderSuggestions = run {
            val isAllowedToSelectHostReminderSuggestions = isAllowedToSelectSuggestions &&
                    // Only organizers can view and send "Host reminders"-suggestions
                    isOrganizer

            if (isAllowedToSelectHostReminderSuggestions && diffInHours != null) {
                // 2 days window [2d, 9h]
                if (diffInHours >= 9 && diffInHours < 48) {
                    return@run hostReminderSuggestions48Hours
                }

                // 9h window: [9h, 3h]
                if (diffInHours >= 3 && diffInHours < 9) {
                    return@run hostReminderSuggestions9Hours
                }

                // 3h window: [3h, 0h]
                if (diffInHours >= 0 && diffInHours < 3) {
                    return@run hostReminderSuggestions3Hours
                }
            }

            listOf()
        }

        icebreakerSuggestions = run {
            if (isAllowedToSelectSuggestions && diffInHours != null) {
                if (diffInHours < 120 && isOrganizer) {
                    // organizers are allowed to select icebreaker suggestions 5 days before
                    return@run icebreakerSuggestions120Hours
                }

                if (diffInHours < 144 && !isOrganizer) {
                    // non-organizers are allowed to select icebreaker suggestions 6 days before
                    return@run icebreakerSuggestions120Hours
                }
            }

            listOf()
        }
    }
}

class MessageSuggestionsViewModelFactory(
    private val listViewModel: MessageListViewModel,
    private val composerViewModel: MessageComposerViewModel,
) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MessageSuggestionsViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return MessageSuggestionsViewModel(listViewModel, composerViewModel) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}