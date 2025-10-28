package com.whoisup.app.stream

import androidx.compose.runtime.Composable
import androidx.compose.ui.res.painterResource
import com.whoisup.app.R
import io.getstream.chat.android.compose.ui.util.ReactionDrawable
import io.getstream.chat.android.compose.ui.util.ReactionIcon
import io.getstream.chat.android.compose.ui.util.ReactionIconFactory

class AmiReactionIconFactory(
    private val supportedReactions: Map<String, ReactionDrawable> = mapOf(
        // Selected versions are identical.
        // We handle selection state differently.
        // We just change the background color (as can be seen inside the `AmiReactionOptions` composable.
        THUMBS_UP to ReactionDrawable(
            iconResId = R.drawable.reaction_thumbs_up,
            selectedIconResId = R.drawable.reaction_thumbs_up,
        ),
        HEART to ReactionDrawable(
            iconResId = R.drawable.reaction_love,
            selectedIconResId = R.drawable.reaction_love,
        ),
        TEARS_OF_JOY to ReactionDrawable(
            iconResId = R.drawable.reaction_lol,
            selectedIconResId = R.drawable.reaction_lol,
        ),
        ASTONISHED to ReactionDrawable(
            iconResId = R.drawable.reaction_astonished,
            selectedIconResId = R.drawable.reaction_astonished,
        ),
        SAD_BUT_RELIEVED to ReactionDrawable(
            iconResId = R.drawable.reaction_sad_but_relieved,
            selectedIconResId = R.drawable.reaction_sad_but_relieved,
        ),
        FOLDED_HANDS to ReactionDrawable(
            iconResId = R.drawable.reaction_folded_hands,
            selectedIconResId = R.drawable.reaction_folded_hands,
        ),
        FIRE to ReactionDrawable(
            iconResId = R.drawable.reaction_fire,
            selectedIconResId = R.drawable.reaction_fire,
        ),
        PARTY_POPPER to ReactionDrawable(
            iconResId = R.drawable.reaction_party_popper,
            selectedIconResId = R.drawable.reaction_party_popper,
        ),
        THUMBS_DOWN to ReactionDrawable(
            iconResId = R.drawable.reaction_thumbs_down,
            selectedIconResId = R.drawable.reaction_thumbs_down,
        ),
        STAR_STRUCK to ReactionDrawable(
            iconResId = R.drawable.reaction_star_struck,
            selectedIconResId = R.drawable.reaction_star_struck,
        ),
        CHECK_MARK_BUTTON to ReactionDrawable(
            iconResId = R.drawable.reaction_check_mark_button,
            selectedIconResId = R.drawable.reaction_check_mark_button,
        ),
        THINKING to ReactionDrawable(
            iconResId = R.drawable.reaction_thinking,
            selectedIconResId = R.drawable.reaction_thinking,
        ),
    ),
) : ReactionIconFactory {

    override fun isReactionSupported(type: String): Boolean {
        return supportedReactions.containsKey(type)
    }

    @Composable
    override fun createReactionIcon(type: String): ReactionIcon {
        val reactionDrawable = requireNotNull(supportedReactions[type])
        return ReactionIcon(
            painter = painterResource(reactionDrawable.iconResId),
            selectedPainter = painterResource(reactionDrawable.selectedIconResId),
        )
    }

    @Composable
    override fun createReactionIcons(): Map<String, ReactionIcon> {
        return listOf(
            THUMBS_UP,
            HEART,
            TEARS_OF_JOY,
            ASTONISHED,
            FIRE,
        ).associateWith {
            createReactionIcon(it)
        }
    }

    companion object {
        private const val THUMBS_UP: String = "thumbs-up"
        private const val HEART: String = "heart"
        private const val TEARS_OF_JOY: String = "tears-of-joy"
        private const val ASTONISHED: String = "astonished"
        private const val SAD_BUT_RELIEVED: String = "sad-but-relieved"
        private const val FOLDED_HANDS: String = "folded-hands"
        private const val FIRE: String = "fire"
        private const val PARTY_POPPER: String = "party-popper"
        private const val THUMBS_DOWN: String = "thumbs-down"
        private const val STAR_STRUCK: String = "star-struck"
        private const val CHECK_MARK_BUTTON: String = "check-mark-button"
        private const val THINKING: String = "thinking"
    }
}