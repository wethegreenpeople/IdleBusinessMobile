package com.uraqt.idlebusiness.data

import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.scalars.ScalarsConverterFactory
import retrofit2.http.*

private const val BASE_URL = "https://idlebusiness.com/api/"
private val retrofit = Retrofit.Builder()
    .addConverterFactory(ScalarsConverterFactory.create())
    .baseUrl(BASE_URL)
    .build()

interface IdleBusinessApiService {
    @GET("auth/createguest")
    fun createGuest(@Header("Authorization") authToken: String): Call<String>

    @GET("auth/gettoken")
    fun getNewAuthToken(@Query("apiKey") api : String) : Call<String>
}

object IdleBusinessApi {
    val retrofitService : IdleBusinessApiService by lazy {
        retrofit.create(IdleBusinessApiService::class.java)
    }
}