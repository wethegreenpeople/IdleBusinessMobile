package com.uraqt.idlebusiness.ui.home

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.recyclerview.widget.DefaultItemAnimator
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.uraqt.idlebusiness.R
import com.uraqt.idlebusiness.data.model.Purchasable
import kotlinx.android.synthetic.main.fragment_home.view.*
import layout.adapters.PurchasableItemAdapter

class HomeFragment : Fragment() {

    private lateinit var homeViewModel: HomeViewModel
    private lateinit var viewOfLayout: View

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

        // Inflate the layout for this fragment
        viewOfLayout = inflater.inflate(R.layout.fragment_home, container, false)

        val recyclerView : RecyclerView = viewOfLayout.findViewById(R.id.purchasable_items)
        homeViewModel.availablePurchases.observe(viewLifecycleOwner, Observer {
            val purchasables = listOf(Purchasable(0, "Number 9", 0.0), Purchasable(0, "Number 10", 0.0))

            val purchasableItemAdapter = PurchasableItemAdapter(purchasables)
            recyclerView?.layoutManager = LinearLayoutManager(context)
            recyclerView?.itemAnimator = DefaultItemAnimator()
            recyclerView?.adapter = purchasableItemAdapter
            viewOfLayout.purchasable_items.adapter = purchasableItemAdapter
        })


        return viewOfLayout
    }
}