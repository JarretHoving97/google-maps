package com.whoisup.app.stream

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicText
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.whoisup.app.R
import com.whoisup.app.components.AmiButton
import com.whoisup.app.components.AmiSimpleMenu
import com.whoisup.app.components.AmiTextField
import com.whoisup.app.ui.theme.CustomTheme
import io.getstream.chat.android.client.ChatClient
import io.getstream.chat.android.compose.ui.theme.ChatTheme
import io.getstream.chat.android.compose.viewmodel.messages.MessageListViewModel

@Composable
fun AmiPinnedMessageMenu(
    listViewModel: MessageListViewModel,
    pinnedMessageViewModel: PinnedMessageViewModel,
) {
    val visible = pinnedMessageViewModel.isModalOpened

    AmiSimpleMenu(
        visible = visible,
        onDismiss = remember(pinnedMessageViewModel) { { pinnedMessageViewModel.closeModal() } }
    ) {
        if (visible) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .clip(ChatTheme.shapes.bottomSheet)
                    .background(CustomTheme.colorScheme.background)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                BasicText(
                    text = stringResource(id = R.string.AmiPinnedMessageModal_title),
                    style = CustomTheme.typography.headingExtraLarge.copy(color = CustomTheme.colorScheme.onBackground),
                )

                val initialPinnedMessage = listViewModel.channel.extraData["pinnedMessage"] as? String

                var value by rememberSaveable { mutableStateOf(initialPinnedMessage ?: "") }

                var loading by rememberSaveable { mutableStateOf(false) }

                AmiTextField(
                    value = value,
                    onValueChange = { value = it },
                    placeholder = stringResource(id = R.string.AmiPinnedMessageModal_input_placeholder),
                    maxLength = 125,
                    maxLines = 5,
                    minLines = 5
                )

                AmiButton(
                    text = stringResource(id = R.string.global_save),
                    onClick = {
                        loading = true
                        ChatClient.instance().channel(listViewModel.channel.cid).updatePartial(
                            set = mapOf(
                                "pinnedMessage" to value
                            )
                        ).enqueue {
                            pinnedMessageViewModel.closeModal()
                            loading = false
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                    loading = loading,
                )
            }
        }
    }
}