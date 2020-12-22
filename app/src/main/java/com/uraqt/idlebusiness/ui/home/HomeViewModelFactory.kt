package com.uraqt.idlebusiness.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.uraqt.idlebusiness.data.BusinessRepository

class HomeViewModelFactory(businessId : Int) : ViewModelProvider.Factory {
    private val _businessId : Int = businessId

    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(HomeViewModel::class.java)) {
            val businessRepo = BusinessRepository()
            return HomeViewModel(_businessId, businessRepo) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}