import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Views/Login/Login.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/BusinessInfo.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/PurchasableCards.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/PurchaseAssetsVM.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Stores/BusinessStore.dart';
import '../../Views/PurchaseAssets/CustomColors.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class PurchaseAssets extends StatefulWidget {
  @override
  _PurchaseAssetsState createState() => _PurchaseAssetsState();
}

class _PurchaseAssetsState extends State<PurchaseAssets> {
  _PurchaseAssetsState();
  PurchaseAssetsVM viewModel;
  BusinessInfo _businessInfo;
  int index;
  PersistentTabController controller = PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
    index = 0;
  }

  void updateViews() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<Business> _getBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final businessId = prefs.getString('businessId');
      final business = await fetchBusiness(businessId);
      return business;
    } catch (Exception) {
      return null;
    }
  }

  Future<Widget> _getPurchasableCards(String purchasableTypeId) async {
    try {
      return PurchasableCards(
        viewModel: this.viewModel,
        purchasableTypeId: purchasableTypeId,
      );
    } catch (Exception) {
      return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: CustomColors.colorPrimaryBlue,
            appBar: AppBar(
              title: Text("Purchase Assets"),
              backgroundColor: CustomColors.colorPrimaryBlueAccent,
              bottom: TabBar(tabs: [
                Tab(
                    icon: Icon(Icons.face),
                    text: "Employees",
                    iconMargin: EdgeInsets.only(bottom: 5.0)),
                Tab(
                    icon: Icon(Icons.business_center),
                    text: "Items",
                    iconMargin: EdgeInsets.only(bottom: 5.0)),
                Tab(
                    icon: Icon(Icons.home),
                    text: "Real Estate",
                    iconMargin: EdgeInsets.only(bottom: 5.0)),
              ]),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                      child: SizedBox(),
                      decoration:
                          BoxDecoration(color: CustomColors.colorPrimaryBlue)),
                  ListTile(
                    title: Text('Log out'),
                    onTap: () {
                      setState(() {
                        void _setLoginState() async {
                          final prefs = await SharedPreferences.getInstance();
                          setState(() {
                            prefs.setBool('isSignedIn', false);
                          });
                        }

                        void pushLogin() async {
                          await pushNewScreen(
                            context,
                            screen: LoginPage(),
                            withNavBar: false,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        }

                        _setLoginState();
                        pushLogin();
                      });
                    },
                  )
                ],
              ),
            ),
            body: FutureBuilder(
              future: _getBusiness(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (viewModel == null)
                    viewModel = PurchaseAssetsVM(snapshot.data);
                  if (_businessInfo == null)
                    _businessInfo = BusinessInfo(viewModel: this.viewModel);
                  return Center(
                    child: TabBarView(children: [
                      Column(
                        children: <Widget>[
                          _businessInfo,
                          FutureBuilder(
                            future: _getPurchasableCards("1"),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data;
                              }
                              return CircularProgressIndicator();
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          _businessInfo,
                          FutureBuilder(
                            future: _getPurchasableCards("2"),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data;
                              }
                              return CircularProgressIndicator();
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          _businessInfo,
                          FutureBuilder(
                            future: _getPurchasableCards("3"),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data;
                              }
                              return CircularProgressIndicator();
                            },
                          ),
                        ],
                      )
                    ]),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),
      ),
    );
  }
}
