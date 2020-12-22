package com.uraqt.idlebusiness.ui.home

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
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
        val textView: TextView = root.findViewById(R.id.text_home)
        homeViewModel.text.observe(viewLifecycleOwner, Observer {
            textView.text = it
        })

        val businessCash: TextView = root.findViewById(R.id.text_businessTotalCash)
        homeViewModel.business.observe(viewLifecycleOwner, Observer {
            businessCash.text = it.Cash.toString()
        })


        return root
    }
}