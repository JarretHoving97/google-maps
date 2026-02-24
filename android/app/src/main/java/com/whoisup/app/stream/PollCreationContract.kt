package com.whoisup.app.stream

import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Parcelable
import androidx.activity.result.contract.ActivityResultContract
import com.whoisup.app.PollCreationActivity
import com.whoisup.app.PollCreationData
import kotlinx.parcelize.Parcelize

class PollCreationContract : ActivityResultContract<Unit, PollCreationContract.Result?>() {
    @Parcelize
    class Result(
        override val question: String,
        override val options: List<String>,
        override val multipleVotesAllowed: Boolean
    ) : PollCreationData, Parcelable

    override fun createIntent(context: Context, input: Unit): Intent {
        return Intent(context, PollCreationActivity::class.java)
    }

    override fun parseResult(resultCode: Int, intent: Intent?): Result? {
        if (resultCode != RESULT_OK) {
            return null
        }
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent?.getParcelableExtra(KeyResult, Result::class.java)
        } else {
            intent?.getParcelableExtra(KeyResult)
        }
    }

    companion object {
        private const val KeyResult: String = "result"

        fun createResult(activity: PollCreationActivity, result: Result?) {
            if (result != null) {
                val data = Intent().apply {
                    putExtra(KeyResult, result)
                }
                activity.setResult(RESULT_OK, data)
            } else {
                activity.setResult(RESULT_CANCELED)
            }
            activity.finish()
        }
    }
}