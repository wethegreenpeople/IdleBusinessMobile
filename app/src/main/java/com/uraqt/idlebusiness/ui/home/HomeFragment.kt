package com.uraqt.idlebusiness.ui.home

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProviders
import com.uraqt.idlebusiness.R

class HomeFragment : Fragment() {

    private lateinit var homeViewModel: HomeViewModel

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {
        val sharedPref = activity?.getSharedPreferences(
            getString(R.string.sharedPrefs), Context.MODE_PRIVATE)
        val businessId = sharedPref!!.getInt(R.string.current_business_id.toString(), 0)

        homeViewModel =
                ViewModelProviders.of(this, HomeViewModelFactory(businessId)).get(HomeViewModel::class.java)
        val root = inflater.inflate(R.layout.fragment_home, container, false)


        return root
    }
}