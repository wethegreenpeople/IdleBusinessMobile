package layout.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.uraqt.idlebusiness.R
import com.uraqt.idlebusiness.data.model.Purchasable


class PurchasableItemAdapter(var purchasables : List<Purchasable>) : RecyclerView.Adapter<PurchasableItemAdapter.ViewHolder>() {
    lateinit var context : Context

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): PurchasableItemAdapter.ViewHolder {
        val view: View =
            LayoutInflater.from(parent.context).inflate(R.layout.purchasable_item_layout, parent, false)
        val viewHolder = ViewHolder(view)
        context = parent.context
        return viewHolder
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        var purchasable : Purchasable = purchasables[position]

        holder.purchasableName.setText(purchasable.Name);
    }

    override fun getItemCount(): Int {
        return purchasables.size
    }

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var purchasableName : TextView = itemView.findViewById(R.id.purchasable_name)
    }
}