package com.whoisup.app.stream

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Parcelable
import androidx.activity.result.contract.ActivityResultContract
import com.whoisup.app.PollCreationActivity
import com.whoisup.app.PollCreationData
import kotlinx.parcelize.Parcelize

@Parcelize
class PollCreationResult(
    override val question: String,
    override val options: List<String>,
    override val multipleVotesAllowed: Boolean
) : PollCreationData, Parcelable

class PollCreationContract : ActivityResultContract<Unit, PollCreationResult?>() {

    override fun createIntent(context: Context, input: Unit): Intent {
        return PollCreationActivity.getIntent(context)
    }

    override fun parseResult(resultCode: Int, intent: Intent?): PollCreationResult? {
        if (resultCode != Activity.RESULT_OK) {
            return null
        }
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent?.getParcelableExtra(PollCreationActivity.KeyResult, PollCreationResult::class.java)
        } else {
            intent?.getParcelableExtra(PollCreationActivity.KeyResult)
        }
    }
}