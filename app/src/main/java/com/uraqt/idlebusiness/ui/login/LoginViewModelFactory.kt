package com.uraqt.idlebusiness.ui.login

import android.content.SharedPreferences
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.uraqt.idlebusiness.data.LoginDataSource
import com.uraqt.idlebusiness.data.LoginRepository

/**
 * ViewModel provider factory to instantiate LoginViewModel.
 * Required given LoginViewModel has a non-empty constructor
 */
class LoginViewModelFactory(prefs : SharedPreferences) : ViewModelProvider.Factory {
    private val _prefs = prefs

    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(LoginViewModel::class.java)) {
            return LoginViewModel(
                loginRepository = LoginRepository(
                    dataSource = LoginDataSource()
                ),
                appPrefs = _prefs
            ) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}