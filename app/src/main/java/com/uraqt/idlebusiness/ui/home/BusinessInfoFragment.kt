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

// TODO: Rename parameter arguments, choose names that match
// the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
private const val ARG_PARAM1 = "param1"
private const val ARG_PARAM2 = "param2"

/**
 * A simple [Fragment] subclass.
 * Use the [BusinessInfoFragment.newInstance] factory method to
 * create an instance of this fragment.
 */
class BusinessInfoFragment : Fragment() {
    // TODO: Rename and change types of parameters
    private var param1: String? = null
    private var param2: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        arguments?.let {
            param1 = it.getString(ARG_PARAM1)
            param2 = it.getString(ARG_PARAM2)
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val sharedPref = activity?.getSharedPreferences(
            getString(R.string.sharedPrefs), Context.MODE_PRIVATE)
        val businessId = sharedPref!!.getInt(R.string.current_business_id.toString(), 0)

        val homeViewModel =
            ViewModelProviders.of(this, HomeViewModelFactory(businessId)).get(HomeViewModel::class.java)
        val root = inflater.inflate(R.layout.fragment_business_info, container, false)

        val businessCash: TextView = root.findViewById(R.id.text_businessTotalCash)
        val businessCashPerSecond : TextView = root.findViewById(R.id.text_businessCashPerSecond)
        homeViewModel.business.observe(viewLifecycleOwner, Observer {
            businessCash.text = it.Cash.toString()
            businessCashPerSecond.text = it.CashPerSecond.toString()
        })


        return root
    }

    companion object {
        /**
         * Use this factory method to create a new instance of
         * this fragment using the provided parameters.
         *
         * @param param1 Parameter 1.
         * @param param2 Parameter 2.
         * @return A new instance of fragment BusinessInfoFragment.
         */
        // TODO: Rename and change types and number of parameters
        @JvmStatic
        fun newInstance(param1: String, param2: String) =
            BusinessInfoFragment().apply {
                arguments = Bundle().apply {
                    putString(ARG_PARAM1, param1)
                    putString(ARG_PARAM2, param2)
                }
            }
    }
}