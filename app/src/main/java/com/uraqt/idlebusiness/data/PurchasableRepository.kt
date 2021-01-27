package com.uraqt.idlebusiness.data

import com.beust.klaxon.Klaxon
import com.uraqt.idlebusiness.data.model.Purchasable
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class PurchasableRepository {
    fun getPurchasablesForBusiness(bearerToken: String, businessId : Int, purchasableTypeId : Int, callback: (result: Purchasable) -> Unit) {
        try {
            IdleBusinessApi.retrofitService.getAvailablePurchasesForBusiness("Bearer $bearerToken", businessId.toString(), purchasableTypeId.toString()).enqueue(
                object : Callback<String> {
                    override fun onFailure(call: Call<String>, t: Throwable) {
                        throw Exception("Couldn't retrieve purchasables for business")
                    }

                    override fun onResponse(call: Call<String>, response: Response<String>) {
                        val purchasables =
                            Klaxon().parse<Purchasable>(json = response.body() ?: "")
                        callback.invoke(purchasables!!)
                    }
                })

        } catch (e: Throwable) {
            throw e
        }
    }
}