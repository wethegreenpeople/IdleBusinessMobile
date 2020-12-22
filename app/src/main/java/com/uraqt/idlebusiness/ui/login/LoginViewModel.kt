package com.uraqt.idlebusiness.ui.login

import android.content.SharedPreferences
import android.util.Patterns
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.uraqt.idlebusiness.R
import com.uraqt.idlebusiness.data.LoginRepository
import com.uraqt.idlebusiness.data.Result
import com.uraqt.idlebusiness.data.model.LoggedInUser

class LoginViewModel(private val loginRepository: LoginRepository, private val appPrefs : SharedPreferences) : ViewModel() {

    private val _loginForm = MutableLiveData<LoginFormState>()
    val loginFormState: LiveData<LoginFormState> = _loginForm

    private val _loginResult = MutableLiveData<LoginResult>()
    val loginResult: LiveData<LoginResult> = _loginResult

    private val _loginBusinessResult = MutableLiveData<LoggedInUser>()
    val loginBusinessResult : LiveData<LoggedInUser> = _loginBusinessResult

    fun login(username: String, password: String) {
        // can be launched in a separate asynchronous job
        val result = loginRepository.login(username, password)

        if (result is Result.Success) {
            _loginResult.value =
                LoginResult(success = LoggedInUserView(displayName = "pp"))
        } else {
            _loginResult.value = LoginResult(error = R.string.login_failed)
        }
    }

    fun guestLogin() {
        loginRepository.guestLogin { result ->
            _loginBusinessResult.value = result
        }
    }

    fun saveBusinessIdToPrefs(businessId : Int) {
        with (appPrefs.edit()) {
            putInt(R.string.current_business_id.toString(), businessId)
            apply()
        }
    }

    fun saveAuthTokenToPrefs(authToken : String) {
        with (appPrefs.edit()) {
            putString(R.string.current_auth_token.toString(), authToken)
            apply()
        }
    }

    fun loginDataChanged(username: String, password: String) {
        if (!isUserNameValid(username)) {
            _loginForm.value = LoginFormState(usernameError = R.string.invalid_username)
        } else if (!isPasswordValid(password)) {
            _loginForm.value = LoginFormState(passwordError = R.string.invalid_password)
        } else {
            _loginForm.value = LoginFormState(isDataValid = true)
        }
    }

    // A placeholder username validation check
    private fun isUserNameValid(username: String): Boolean {
        return if (username.contains('@')) {
            Patterns.EMAIL_ADDRESS.matcher(username).matches()
        } else {
            username.isNotBlank()
        }
    }

    // A placeholder password validation check
    private fun isPasswordValid(password: String): Boolean {
        return password.length > 5
    }
}