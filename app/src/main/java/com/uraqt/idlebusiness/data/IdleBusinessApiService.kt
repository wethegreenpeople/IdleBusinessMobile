package com.uraqt.idlebusiness.data

import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.scalars.ScalarsConverterFactory
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Path
import retrofit2.http.Query

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

    @GET("purchasable/getpurchase")
    fun getAvailablePurchasesForBusiness(@Header("Authorization") authToken: String,
                                       @Query("businessId") businessId : String,
                                       @Query("purchasableTypeId") purchasableTypeId : String) : Call<String>

    @GET("/api/Business/{businessId}")
    fun getBusiness(@Header("Authorization") authToken : String,
                    @Path(value = "businessId", encoded = true) businessId : Int) : Call<String>
}

object IdleBusinessApi {
    val retrofitService : IdleBusinessApiService by lazy {
        retrofit.create(IdleBusinessApiService::class.java)
    }
}