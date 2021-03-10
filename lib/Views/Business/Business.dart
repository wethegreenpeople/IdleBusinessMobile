import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:idlebusiness_mobile/Models/Investment.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Views/Business/BusinessVM.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/CustomColors.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sizer/sizer.dart';

class BusinessPage extends StatefulWidget {
  final int _businessId;

  BusinessPage(this._businessId);

  @override
  State<StatefulWidget> createState() => new _BusinessPageState(_businessId);
}

class _BusinessPageState extends State<BusinessPage> {
  int _businessId;
  BusinessVM _viewModel;

  _BusinessPageState(int businessId) {
    _viewModel = BusinessVM(businessId);
    _businessId = businessId;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Business>(
        future: _viewModel.getBusiness(_businessId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                appBar: new AppBar(
                  backgroundColor: CustomColors.colorPrimaryBlueAccent,
                  title: new Text("Business Info"),
                ),
                backgroundColor: CustomColors.colorPrimaryBlue,
                body: ListView(
                  children: <Widget>[
                    businessInfoCard(snapshot.data),
                    businessInvestments(snapshot.data),
                    businessEspionages(snapshot.data),
                  ],
                ));
          }
          return Scaffold(
            appBar: new AppBar(
              backgroundColor: CustomColors.colorPrimaryBlueAccent,
              title: new Text("Business Info"),
            ),
            backgroundColor: CustomColors.colorPrimaryBlue,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  Widget businessInfoCard(Business business) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    title: Text(
                  business.name,
                  style: TextStyle(
                    fontSize: 18.0.sp,
                    fontStyle: FontStyle.italic,
                  ),
                )),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                          child: ListTile(
                              leading: Icon(Icons.attach_money),
                              title: Text(
                                  NumberFormat.compact().format(business.cash)),
                              subtitle: Text('Cash'))),
                    ),
                    Expanded(
                      child: Card(
                          child: ListTile(
                              leading: Icon(Icons.schedule),
                              title: Text(NumberFormat.compact()
                                  .format(business.cashPerSecond)),
                              subtitle: Text('Cash per second'))),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                          child: ListTile(
                              leading: Icon(Icons.score),
                              title: Text(NumberFormat.compact()
                                  .format(business.businessScore)),
                              subtitle: Text('Score'))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget businessInvestments(Business business) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                      title: Text(
                    business.name + "'s Investments",
                    style: TextStyle(
                      fontSize: 18.0.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  )),
                  SingleChildScrollView(
                    child: Container(
                      height: 20.0.h,
                      child: ListView(
                        children: [
                          ...businessInvestmentCards(business.investments)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget businessEspionages(Business business) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    title: Text(
                  business.name + "'s Espionages",
                  style: TextStyle(
                    fontSize: 18.0.sp,
                    fontStyle: FontStyle.italic,
                  ),
                )),
              ],
            ),
          ),
        )
      ],
    );
  }

  List<Widget> businessInvestmentCards(List<Investment> investments) {
    if (investments.length == 0) {
      List<Widget> widget = [
        Row(
          children: [
            Expanded(
              child: Card(
                  child: ListTile(
                leading: Icon(MdiIcons.chartBar),
                title: Text("No Investments"),
              )),
            ),
          ],
        )
      ];
      return widget;
    }

    List<Widget> widgets = [];
    investments.forEach((element) {
      widgets.add(FutureBuilder<Business>(
        future: Business().getBusiness(element.businessInvestedInId.toString()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Row(
              children: [
                Expanded(
                  child: Card(
                      child: ListTile(
                          leading: Icon(MdiIcons.chartBar),
                          title: Text("Invested in " + snapshot.data.name),
                          subtitle: Text("Invested: \$" +
                              NumberFormat.decimalPattern()
                                  .format(element.investmentAmount)))),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: Card(
                    child: ListTile(
                  leading: Icon(MdiIcons.chartBar),
                  title: Text("Investment"),
                )),
              ),
            ],
          );
        },
      ));
    });

    return widgets;
  }
}
