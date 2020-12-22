package com.uraqt.idlebusiness.data

import com.beust.klaxon.Klaxon
import com.uraqt.idlebusiness.data.model.LoggedInUser
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class BusinessRepository() {

    fun getBusiness(bearerToken: String, businessId : Int, callback: (result: LoggedInUser) -> Unit) {
        try {
            IdleBusinessApi.retrofitService.getBusiness("Bearer $bearerToken", businessId).enqueue(
                object : Callback<String> {
                    override fun onFailure(call: Call<String>, t: Throwable) {
                        throw Exception("Couldn't do it")
                    }

                    override fun onResponse(call: Call<String>, response: Response<String>) {
                        val business =
                            Klaxon().parse<LoggedInUser>(json = response.body() ?: "")
                        callback.invoke(business!!)
                    }
                })

        } catch (e: Throwable) {
            throw e
        }
    }
}