import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Stores/PurchasableStore.dart';
import 'package:idlebusiness_mobile/Views/CreateItem/CreateItemVM.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/CustomColors.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/PurchaseAssets.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class CreateItemPage extends StatefulWidget {
  final Business _business;
  CreateItemPage(this._business);

  @override
  State<StatefulWidget> createState() => new _CreateItemPageState(_business);
}

class _CreateItemPageState extends State<CreateItemPage> {
  Business _business;
  CreateItemVM _viewModel;
  _CreateItemPageState(this._business);

  @override
  void initState() {
    if (_viewModel == null)
      _viewModel = new CreateItemVM(context, this._business);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: CustomColors.colorPrimaryBlueAccent,
        title: new Text("Create a marketplace item!"),
      ),
      backgroundColor: CustomColors.colorPrimaryBlue,
      body: Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Card(
                        color: Colors.white,
                        child: ListTile(
                            leading: Icon(Icons.info),
                            title: Text("Creating a marketplace item"),
                            subtitle: RichText(
                                text: TextSpan(
                              children: [
                                TextSpan(
                                    style: TextStyle(color: Colors.grey),
                                    text:
                                        "To create a marketplace item, pick a name for your item and max amount that can be sold. Be mindful of the cost per item, if it's too high you might struggle to find buyers!\n\n"),
                                TextSpan(
                                    style: TextStyle(color: Colors.grey),
                                    text:
                                        "Once your item is created, you cannot create another item until all of your current stock has been sold.\n\n"),
                                TextSpan(
                                    style: TextStyle(color: Colors.grey),
                                    text:
                                        "Everytime your item is purchased, the profit will be added directly to your cash."),
                              ],
                            )))),
                    _itemCreationCard()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemCreationCard() {
    return Card(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(15, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: _viewModel.itemNameController,
                    maxLines: 1,
                    keyboardType: TextInputType.name,
                    autofocus: false,
                    decoration: new InputDecoration(
                        hintText: 'Marketplace item name',
                        icon: new Icon(
                          MdiIcons.text,
                          color: Colors.grey,
                        )),
                  ))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListTile(
                      minLeadingWidth: 5.0,
                      leading: Icon(MdiIcons.numeric9BoxMultipleOutline),
                      title: Text(
                        "Production Amount",
                        style: TextStyle(fontSize: 12.0.sp),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: NumberPicker(
                    minValue: 10,
                    maxValue: 100,
                    value: _viewModel.currentProductionAmountValue,
                    infiniteLoop: true,
                    axis: Axis.horizontal,
                    onChanged: (value) => setState(
                        () => _viewModel.currentProductionAmountValue = value),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 40, 0, 0),
                  child: Row(
                    children: [
                      Text(
                        "Cost to produce: ",
                        style: TextStyle(fontSize: 12.0.sp),
                      ),
                      Text(
                        NumberFormat.compactSimpleCurrency()
                            .format(_viewModel.costToProduce),
                        style: TextStyle(
                            fontSize: 10.0.sp, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Row(
                    children: [
                      Text(
                        "Cost per item: ",
                        style: TextStyle(fontSize: 12.0.sp),
                      ),
                      Text(
                        NumberFormat.compactSimpleCurrency()
                            .format(_viewModel.costPerItem),
                        style: TextStyle(
                            fontSize: 10.0.sp, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Row(
                    children: [
                      Text(
                        "CPS gain per item: ",
                        style: TextStyle(fontSize: 12.0.sp),
                      ),
                      Text(
                        NumberFormat.compactSimpleCurrency()
                            .format(_viewModel.cpsGainPerItem),
                        style: TextStyle(
                            fontSize: 10.0.sp, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                  child: Row(
                    children: [
                      Text(
                        "Revenue generated: ",
                        style: TextStyle(fontSize: 12.0.sp),
                      ),
                      Text(
                        NumberFormat.compactSimpleCurrency()
                            .format(_viewModel.profit),
                        style: TextStyle(
                            fontSize: 10.0.sp, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            var response = await PurchasableStore()
                                .createMarketplaceItem(
                                    _viewModel.business.id,
                                    _viewModel.itemNameController.text,
                                    _viewModel.currentProductionAmountValue);
                            if (response.success)
                              _pushPurchaseAssetsScreen(context);
                            else {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text(':('),
                                        content: Text(response.returnValue),
                                      ));
                            }
                          },
                          child: Text('Create Item')),
                    ),
                  ],
                )),
          ],
        ));
  }

  Future<void> _pushPurchaseAssetsScreen(BuildContext context) async {
    await pushNewScreen(
      context,
      screen: PurchaseAssets(),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
