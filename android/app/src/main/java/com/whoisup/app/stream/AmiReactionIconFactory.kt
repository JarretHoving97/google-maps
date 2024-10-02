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
        FIRE to ReactionDrawable(
            iconResId = R.drawable.reaction_fire,
            selectedIconResId = R.drawable.reaction_fire,
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
        return supportedReactions.mapValues {
            createReactionIcon(it.key)
        }
    }

    companion object {
        private const val THUMBS_UP: String = "thumbs-up"
        private const val HEART: String = "heart"
        private const val TEARS_OF_JOY: String = "tears-of-joy"
        private const val ASTONISHED: String = "astonished"
        private const val FIRE: String = "fire"
    }
}