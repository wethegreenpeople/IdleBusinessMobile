package com.uraqt.idlebusiness.data

import com.beust.klaxon.Klaxon
import com.uraqt.idlebusiness.BuildConfig
import com.uraqt.idlebusiness.data.model.LoggedInUser
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

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
            IdleBusinessApi.retrofitService.getNewAuthToken(BuildConfig.IdleBusinessApi).enqueue(
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
    private fun attemptGuestLogin(bearerToken : String, callback : (result : LoggedInUser) -> Unit) {
        try {
            IdleBusinessApi.retrofitService.createGuest("Bearer $bearerToken").enqueue(
                object: Callback<String> {
                    override fun onFailure(call: Call<String>, t: Throwable) {
                        throw Exception("Couldn't do it")
                    }

                    override fun onResponse(call: Call<String>, response: Response<String>) {
                        val guestAccount = Klaxon().parse<LoggedInUser>(json = response.body() ?: "")
                        callback.invoke(guestAccount!!)
                    }
                })

        } catch (e: Throwable) {
            throw e
        }
    }
    fun guestLogin(callback : (result : LoggedInUser) -> Unit) {
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