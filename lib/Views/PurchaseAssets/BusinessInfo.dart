import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/PurchaseAssetsVM.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:sizer/sizer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BusinessInfo extends StatefulWidget {
  final PurchaseAssetsVM viewModel;

  BusinessInfo({this.viewModel});

  @override
  _BusinessInfoState createState() => _BusinessInfoState(viewModel: viewModel);
}

class _BusinessInfoState extends State<BusinessInfo> {
  Future<Business> futureBusiness;
  final PurchaseAssetsVM viewModel;
  bool isCollapsed = true;
  _BusinessInfoState({
    this.viewModel,
  });

  @override
  void initState() {
    super.initState();
    updateBusinessGains(this.viewModel.business.id.toString());
    viewModel.startCashIncreaseTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseAssetsVM>(
      builder: (context, value, child) {
        return InkWell(
            onTap: () {
              isCollapsed = !isCollapsed;
              setState(() {});
            },
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: collapsedCards(),
              secondChild: expandedCards(),
              crossFadeState: isCollapsed
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ));
      },
    );
  }

  void updateBusinessInfo() async {
    if (mounted) {
      setState(() {});
    }
  }

  Widget businessCards() {
    if (isCollapsed) {
      return collapsedCards();
    }
    return expandedCards();
  }

  Widget collapsedCards() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      height: 78,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          fakeCardStack(
              Icons.attach_money,
              Text(NumberFormat.compact()
                  .format(this.viewModel.business.cash ?? 0)),
              "Cash"),
          fakeCardStack(
              Icons.schedule,
              Text(NumberFormat.compact()
                  .format(this.viewModel.business.cashPerSecond ?? 0)),
              "Cash-per-second"),
        ],
      ),
    );
  }

  Widget expandedCards() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      height: 33.0.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * .5,
            child: ListView(
              children: [
                Card(
                    child: ListTile(
                        leading: Icon(Icons.attach_money),
                        title: Text(NumberFormat.compact()
                            .format(this.viewModel.business.cash ?? 0)),
                        subtitle: Text('Cash'))),
                Card(
                    child: ListTile(
                        leading: Icon(Icons.business_center),
                        title: Text(NumberFormat.compact().format(
                                this.viewModel.business.amountOwnedItems ?? 0) +
                            " / " +
                            NumberFormat.compact().format(
                                this.viewModel.business.maxItemAmount ?? 0)),
                        subtitle: Text('Items'))),
                Card(
                    child: ListTile(
                        leading: Icon(MdiIcons.sword),
                        title: Text(NumberFormat.percentPattern().format(
                            this.viewModel.business.espionageChance ?? 0)),
                        subtitle: Text('Espionage Chance')))
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .5,
            child: ListView(
              children: [
                Card(
                    child: ListTile(
                        leading: Icon(Icons.schedule),
                        title: Text(NumberFormat.compact().format(
                            this.viewModel.business.cashPerSecond ?? 0)),
                        subtitle: Text('Cash-per-second'))),
                Card(
                    child: ListTile(
                        leading: Icon(Icons.face),
                        title: Text((NumberFormat.compact().format(
                                this.viewModel.business.amountEmployed ?? 0) +
                            " / " +
                            (NumberFormat.compact().format(
                                this.viewModel.business.maxEmployeeAmount ??
                                    0)))),
                        subtitle: Text('Employees'))),
                Card(
                    child: ListTile(
                        leading: Icon(MdiIcons.shieldOutline),
                        title: Text(NumberFormat.percentPattern().format(
                            this.viewModel.business.espionageDefense ?? 0)),
                        subtitle: Text('Espionage Defense')))
              ],
            ),
          ),
        ],
      ),
    );
  }

  // card stack with "fake" card behind the top-most card
  Widget fakeCardStack(IconData icon, Text content, String title) {
    return Container(
        width: MediaQuery.of(context).size.width * .5,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 4.0, left: 4.0),
              child: Card(
                  child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Text(
                      "Content"), // bullshit content to ensure we 'expand' the card
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, bottom: 10.0),
              child: Card(
                child: ListTile(
                  leading: Icon(icon),
                  title: content,
                  subtitle: Text(title),
                ),
                elevation: 5,
              ),
            ),
          ],
        ));
  }
}
