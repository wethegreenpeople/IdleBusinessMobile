import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Views/BusinessDirectory/DirectoryVM.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../PurchaseAssets/CustomColors.dart';
import 'package:sizer/sizer.dart';

class DirectoryPage extends StatefulWidget {
  DirectoryPage();

  @override
  State<StatefulWidget> createState() => new _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  Business business;
  _DirectoryPageState();
  DirectoryVM _viewModel;

  @override
  void initState() {
    super.initState();
    if (_viewModel == null) _viewModel = DirectoryVM();
    getSharedPrefs().then((value) {
      var businessId = value.getString('businessId');
      Business().getBusiness(businessId).then((value) {
        this.business = value;
        setState(() {});
      });
    });

    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.resumed.toString()) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: CustomColors.colorPrimaryBlueAccent,
          title: new Text('Business Directory'),
        ),
        backgroundColor: CustomColors.colorPrimaryBlue,
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            return;
          },
          child: ListView(
            children: <Widget>[
              myBusinessCard(),
              topBusinesses(),
              searchForBusinessCard(),
              randomBusinesses()
            ],
          ),
        ));
  }

  Widget _showCircularProgress() {
    return Center(child: CircularProgressIndicator());
  }

  Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Widget topBusinesses() {
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
                  "Most Successful Businesses",
                  style: TextStyle(
                    fontSize: 18.0.sp,
                    fontStyle: FontStyle.italic,
                  ),
                )),
                FutureBuilder(
                  future: getLeaderboard(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return leaderboardCardsFromList(snapshot.data);
                    }
                    return CircularProgressIndicator();
                  },
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget randomBusinesses() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
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
                    "Take a look at...",
                    style: TextStyle(
                      fontSize: 18.0.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  )),
                  FutureBuilder(
                    future: _viewModel.getRandomBusinesses(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return randomBusinessCardsFromList(snapshot.data);
                      }
                      return CircularProgressIndicator();
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget myBusinessCard() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                this.business == null
                    ? _showCircularProgress()
                    : ListTile(
                        title: Text(
                        this.business?.name ?? "",
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
                              leading: Icon(Icons.account_balance),
                              title: Text(NumberFormat.compact().format(
                                  this.business?.lifeTimeEarnings ?? 0)),
                              subtitle: Text('Life Time'))),
                    ),
                    Expanded(
                      child: Card(
                          child: ListTile(
                              leading: Icon(Icons.score),
                              title: Text(NumberFormat.compact()
                                  .format(this.business?.businessScore ?? 0)),
                              subtitle: Text('Score'))),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget searchForBusinessCard() {
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
                  "Find Business",
                  style: TextStyle(
                    fontSize: 18.0.sp,
                    fontStyle: FontStyle.italic,
                  ),
                )),
                Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: TextFormField(
                        controller: _viewModel.searchForBusinessController,
                        maxLines: 1,
                        keyboardType: TextInputType.name,
                        autofocus: false,
                        decoration: new InputDecoration(
                            hintText: 'Lookup business',
                            icon: new Icon(
                              Icons.search,
                              color: Colors.grey,
                            )),
                      ),
                    )),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(10.0.w, 1.0.h, 10.0.w, 1.0.h),
                        child: ElevatedButton(
                            onPressed: () async {
                              var result = await _viewModel.searchForBusiness(
                                  _viewModel.searchForBusinessController.text);
                              if (result != null) {
                                _viewModel.navigateToBusiness(
                                    context, result.id);
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: Text(':('),
                                          content: Text("Could not find " +
                                              _viewModel
                                                  .searchForBusinessController
                                                  .text),
                                        ));
                              }
                            },
                            child: Text('Search')),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<List<Business>> getLeaderboard() async {
    try {
      return await fetchLeaderboard();
    } catch (Exception) {
      return null;
    }
  }

  Widget leaderboardCardsFromList(List<Business> businessesList) {
    if (businessesList == null || businessesList.isEmpty) return null;
    var widgets = <Widget>[];

    businessesList.forEach((element) {
      widgets.add(Card(
        child: InkWell(
          onTap: () {
            _viewModel.navigateToBusiness(context, element.id);
          },
          child: ListTile(
            leading: Icon(MdiIcons.trophyVariant),
            title: Text(element.name.toString()),
            subtitle: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.score, size: 15),
                  ),
                  TextSpan(
                      style: TextStyle(color: Colors.grey),
                      text: NumberFormat.decimalPattern()
                          .format(element.businessScore)),
                ],
              ),
            ),
          ),
        ),
      ));
    });

    return ListView(
      shrinkWrap: true,
      children: widgets,
    );
  }

  Widget randomBusinessCardsFromList(List<Business> businessesList) {
    if (businessesList == null || businessesList.isEmpty) return null;
    var widgets = <Widget>[];

    businessesList.forEach((element) {
      widgets.add(Card(
        child: InkWell(
          onTap: () {
            _viewModel.navigateToBusiness(context, element.id);
          },
          child: ListTile(
            title: Text(element.name.toString()),
            subtitle: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.attach_money, size: 15),
                  ),
                  TextSpan(
                      style: TextStyle(color: Colors.grey),
                      text: NumberFormat.compact().format(element.cash)),
                  WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Icon(Icons.schedule, size: 15),
                    ),
                  ),
                  TextSpan(
                      style: TextStyle(color: Colors.grey),
                      text:
                          NumberFormat.compact().format(element.cashPerSecond)),
                ],
              ),
            ),
          ),
        ),
      ));
    });

    return ListView(
      shrinkWrap: true,
      children: widgets,
    );
  }
}
