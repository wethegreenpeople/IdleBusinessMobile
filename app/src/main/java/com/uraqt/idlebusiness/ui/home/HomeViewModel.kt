package com.uraqt.idlebusiness.ui.home

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.uraqt.idlebusiness.BuildConfig
import com.uraqt.idlebusiness.data.BusinessRepository
import com.uraqt.idlebusiness.data.IdleBusinessApi
import com.uraqt.idlebusiness.data.model.LoggedInUser
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class HomeViewModel(businessId : Int, businessRepository: BusinessRepository) : ViewModel() {
    private val _businessId : Int = businessId
    private val _businessRepository = businessRepository
    private val _text = MutableLiveData<String>().apply {
        value = "This is home Fragment"
    }
    val text: LiveData<String> = _text

    private val _totalBusinessCash = MutableLiveData<String>()
    val totalBusinessCash : LiveData<String> = _totalBusinessCash

    private val _business = MutableLiveData<LoggedInUser>()
    var business : MutableLiveData<LoggedInUser> = _business
    init {
        getBusiness(_businessId)
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
    private fun getBusiness(businessId : Int) {
        var bearerToken = ""
        getNewBearerToken { tokenResult ->
            bearerToken = tokenResult
            _businessRepository.getBusiness(bearerToken, businessId) { businessResult ->
                business.postValue(businessResult)
            }
        }

    }
}