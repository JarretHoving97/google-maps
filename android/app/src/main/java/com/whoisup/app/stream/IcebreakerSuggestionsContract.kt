package com.whoisup.app.stream

import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Parcelable
import androidx.activity.result.contract.ActivityResultContract
import com.whoisup.app.IcebreakerSuggestionsActivity
import kotlinx.parcelize.Parcelize

class IcebreakerSuggestionsContract : ActivityResultContract<IcebreakerSuggestionsContract.Input, IcebreakerSuggestionsContract.Result?>() {
    @Parcelize
    class Input(
        val suggestions: List<String>,
    ) : Parcelable

    @Parcelize
    class Result(
        val selectedIcebreakerSuggestionText: String,
    ) : Parcelable

    override fun createIntent(context: Context, input: Input): Intent {
        return Intent(context, IcebreakerSuggestionsActivity::class.java).apply {
            putExtra(KeyInput, input)
        }
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
        private const val KeyInput: String = "input"
        private const val KeyResult: String = "result"

        fun parseIntent(activity: IcebreakerSuggestionsActivity): Input? {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                activity.intent?.getParcelableExtra(KeyInput, Input::class.java)
            } else {
                activity.intent?.getParcelableExtra(KeyInput)
            }
        }

        fun createResult(activity: IcebreakerSuggestionsActivity, result: Result?) {
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