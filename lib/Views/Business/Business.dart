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
  final int _viewingBusinessId;
  final int _viewedBusinessId;

  BusinessPage(this._viewingBusinessId, this._viewedBusinessId);

  @override
  State<StatefulWidget> createState() =>
      new _BusinessPageState(_viewingBusinessId, _viewedBusinessId);
}

class _BusinessPageState extends State<BusinessPage> {
  int _viewingBusinessId;
  int _viewedBusinessId;
  BusinessVM _viewModel;
  var investmentAmountController = TextEditingController();

  _BusinessPageState(int viewingBusinessId, int viewedBusinessId) {
    _viewModel = BusinessVM(viewingBusinessId, viewedBusinessId);
    _viewingBusinessId = viewingBusinessId;
    _viewedBusinessId = viewedBusinessId;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: CustomColors.colorPrimaryBlue,
        appBar: AppBar(
          title: Text("Business"),
          backgroundColor: CustomColors.colorPrimaryBlueAccent,
          bottom: TabBar(tabs: [
            Tab(
                icon: Icon(Icons.business),
                text: "Info",
                iconMargin: EdgeInsets.only(bottom: 5.0)),
            Tab(
                icon: Icon(Icons.bar_chart),
                text: "Invest",
                iconMargin: EdgeInsets.only(bottom: 5.0)),
            Tab(
                icon: Icon(MdiIcons.sword),
                text: "Espionage",
                iconMargin: EdgeInsets.only(bottom: 5.0)),
          ]),
        ),
        body: TabBarView(
          children: [
            businessInfoTabBarChild(),
            investInBusinessTabBarChild(),
            espionageBusinessTabBarChild()
          ],
        ),
      ),
    );
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
                      height: 15.0.h,
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
                    business.name + "'s Espionages",
                    style: TextStyle(
                      fontSize: 18.0.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  )),
                  SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 15.0.h),
                      child: ListView(
                        children: [
                          ...businessEspionageCards(business.espionages)
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

  List<Widget> businessInvestmentCards(List<Investment> investments) {
    if (investments.length == 0 ||
        !investments.any((element) => element.investmentDirection == 1)) {
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
      if (element.investmentDirection == 1) {
        widgets.add(FutureBuilder<Business>(
          future:
              Business().getBusiness(element.businessInvestedInId.toString()),
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
      }
      ;
    });

    return widgets;
  }

  List<Widget> businessEspionageCards(List<Investment> espionages) {
    if (espionages.length == 0) {
      List<Widget> widget = [
        Row(
          children: [
            Expanded(
              child: Card(
                  child: ListTile(
                leading: Icon(MdiIcons.sword),
                title: Text("No Espionages"),
              )),
            ),
          ],
        )
      ];
      return widget;
    }

    List<Widget> widgets = [];
    espionages.forEach((element) {
      widgets.add(FutureBuilder<Business>(
        future: Business().getBusiness(element.businessInvestedInId.toString()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Row(
              children: [
                Expanded(
                  child: Card(
                      child: ListTile(
                          leading: Icon(MdiIcons.robber),
                          title: Text("Espionaged " + snapshot.data.name),
                          subtitle: Text("Stole: \$" +
                              NumberFormat.decimalPattern()
                                  .format(element.investmentAmount) +
                              " CPS"))),
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
                  title: Text("Espionage"),
                )),
              ),
            ],
          );
        },
      ));
    });

    return widgets;
  }

  Widget businessInfoTabBarChild() {
    return FutureBuilder<Business>(
        future: _viewModel.getBusiness(_viewedBusinessId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: <Widget>[
                businessInfoCard(snapshot.data),
                if (_viewModel.canViewInvestments)
                  businessInvestments(snapshot.data),
                if (_viewModel.canViewEspionages)
                  businessEspionages(snapshot.data),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget investInBusinessCard() {
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
                    "Invest in business",
                    style: TextStyle(
                      fontSize: 18.0.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  subtitle: Text(
                      "Invest in business for one day. Tomorrow, you will collect a percentage of the profits the invested company made between the investment time and market close."),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5.0.w, 0, 0, 0),
                  child: TextFormField(
                    controller: investmentAmountController,
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    autofocus: false,
                    decoration: new InputDecoration(
                        hintText: 'Investment amount (from your CPS)',
                        icon: new Icon(
                          Icons.schedule,
                          color: Colors.grey,
                        )),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(10.0.w, 1.0.h, 10.0.w, 1.0.h),
                        child: ElevatedButton(
                            onPressed: () async {
                              var result = await _viewModel.investInBusiness(
                                  double.parse(
                                      investmentAmountController.text));
                              if (result.success) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text('Success!'),
                                          content: Text("Invested \$" +
                                              investmentAmountController.text +
                                              " in " +
                                              _viewModel.viewedBusinessName),
                                        ));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text(':('),
                                          content: Text(result.returnValue),
                                        ));
                              }

                              setState(() {});
                            },
                            child: Text('Invest')),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget investInBusinessTabBarChild() {
    return FutureBuilder(
        future: _viewModel.getBusiness(this._viewedBusinessId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: <Widget>[
                businessInfoCard(snapshot.data),
                investInBusinessCard(),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget espionageBusinessCard() {
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
                      "Commit espionage",
                      style: TextStyle(
                        fontSize: 18.0.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    isThreeLine: true,
                    subtitle: FutureBuilder(
                      future: Future.wait([
                        _viewModel.getEspionageSuccessChance(),
                        _viewModel.calculateEspionageLoss()
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SizedBox();
                        return RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Chance of success: ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: "${snapshot.data[0]}%\n",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: "Cost of espionage: ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text:
                                    "${_viewModel.viewingBusinessEspionageCost}\n\n",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "If espionage is successful, ${_viewModel.viewedBusinessName} will lose ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: "${snapshot.data[1]}% ",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "of it's current CPS for one day. ${_viewModel.viewedBusinessName} will also gain ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: "5% ",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: "espionage defense. ",
                                style: TextStyle(color: Colors.grey)),
                          ]),
                        );
                      },
                    )),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(10.0.w, 1.0.h, 10.0.w, 1.0.h),
                        child: ElevatedButton(
                            onPressed: () async {
                              var result = await _viewModel.espionageBusiness();
                              if (result.success) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text('Success!'),
                                          content: Text(
                                              "Commited espionage against " +
                                                  _viewModel
                                                      .viewedBusinessName),
                                        ));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text(':('),
                                          content: Text(result.returnValue),
                                        ));
                              }
                            },
                            child: Text('Attempt Espionage')),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget attemptTheftBusinessCard() {
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
                      "Theft",
                      style: TextStyle(
                        fontSize: 18.0.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    isThreeLine: true,
                    subtitle: FutureBuilder(
                      future: _viewModel.getTheftSuccessChance(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SizedBox();
                        return RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Chance of success: ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: "${snapshot.data}%\n",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: "Cost of theft: ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text:
                                    "${_viewModel.viewingBusinessEspionageCost}\n\n",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "If theft is successful you will steal between ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: "1% - 15% ",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "of ${_viewModel.viewedBusinessName}'s cash. ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text:
                                    "${_viewModel.viewedBusinessName} will also gain ",
                                style: TextStyle(color: Colors.grey)),
                            TextSpan(
                                text: "5% ",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: "espionage defense. ",
                                style: TextStyle(color: Colors.grey)),
                          ]),
                        );
                      },
                    )),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(10.0.w, 1.0.h, 10.0.w, 1.0.h),
                        child: ElevatedButton(
                            onPressed: () async {
                              var result =
                                  await _viewModel.attemptTheftOnBusiness();
                              if (result.success) {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                        title: Text('Success!'),
                                        content: Text(result.returnValue)));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text(':('),
                                          content: Text(result.returnValue),
                                        ));
                              }
                            },
                            child: Text('Attempt Theft')),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget espionageBusinessTabBarChild() {
    return FutureBuilder(
        future: _viewModel.getBusiness(this._viewedBusinessId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: <Widget>[
                businessInfoCard(snapshot.data),
                espionageBusinessCard(),
                if (_viewModel.canAttemptTheft) attemptTheftBusinessCard()
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
