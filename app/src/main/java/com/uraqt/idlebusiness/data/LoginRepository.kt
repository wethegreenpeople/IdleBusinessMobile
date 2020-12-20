package com.uraqt.idlebusiness.data

import com.beust.klaxon.Klaxon
import com.uraqt.idlebusiness.R
import com.uraqt.idlebusiness.data.model.LoggedInUser
import com.uraqt.idlebusiness.ui.login.LoggedInUserView
import com.uraqt.idlebusiness.ui.login.LoginResult
import kotlinx.coroutines.delay
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.lang.Exception

/**
 * Class that requests authentication and user information from the remote data source and
 * maintains an in-memory cache of login status and user credentials information.
 */

class LoginRepository(val dataSource: LoginDataSource) {

    // in-memory cache of the loggedInUser object
    var user: LoggedInUser? = null
        private set

    val isLoggedIn: Boolean
        get() = user != null

    init {
        // If user credentials will be cached in local storage, it is recommended it be encrypted
        // @see https://developer.android.com/training/articles/keystore
        user = null
    }

    fun logout() {
        user = null
        dataSource.logout()
    }

    fun login(username: String, password: String): Result<LoggedInUser> {
        // handle login
        val result = dataSource.login(username, password)

        if (result is Result.Success) {
            setLoggedInUser(result.data)
        }

        return result
    }

    private fun getNewBearerToken(callback : (result : String) -> Unit) {
        try {
            IdleBusinessApi.retrofitService.getNewAuthToken("0e97bea9-5b7c-4668-a6d0-09766a83fa89").enqueue(
                object: Callback<String> {
                    override fun onFailure(call: Call<String>, t: Throwable) {
                        throw Exception("Couldn't do it")
                    }

                    override fun onResponse(call: Call<String>, response: Response<String>) {
                        callback.invoke(response.body().toString())
                    }
                })

        } catch (e: Throwable) {
            throw e
        }
    }
    private fun attemptGuestLogin(bearerToken : String, callback : (result : String) -> Unit) {
        try {
            IdleBusinessApi.retrofitService.createGuest("Bearer $bearerToken").enqueue(
                object: Callback<String> {
                    override fun onFailure(call: Call<String>, t: Throwable) {
                        throw Exception("Couldn't do it")
                    }

                    override fun onResponse(call: Call<String>, response: Response<String>) {
                        val guestAccount = Klaxon().parse<LoggedInUser>(json = response.body() ?: "")
                        callback.invoke(guestAccount!!.Name)
                    }
                })

        } catch (e: Throwable) {
            throw e
        }
    }
    fun guestLogin(callback : (result : String) -> Unit) {
        var bearerToken = ""
        getNewBearerToken {
            bearerToken = it
            attemptGuestLogin(it, callback)
        }
    }

    private fun setLoggedInUser(loggedInUser: LoggedInUser) {
        this.user = loggedInUser
        // If user credentials will be cached in local storage, it is recommended it be encrypted
        // @see https://developer.android.com/training/articles/keystore
    }
}