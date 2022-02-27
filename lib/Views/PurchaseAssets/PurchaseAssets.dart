import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Models/BusinessInfoType.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/BusinessInfo.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/PurchasableCards.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/PurchaseAssetsVM.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Stores/BusinessStore.dart';
import '../../Views/PurchaseAssets/CustomColors.dart';
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
    _businessInfo = BusinessInfo(
      viewModel: this.viewModel,
      infoType: BusinessInfoType.cashPerSecond,
    );
  }

  void updateViews() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<PurchaseAssetsVM> _createViewModel() async {
    if (viewModel != null) return viewModel;
    final prefs = await SharedPreferences.getInstance();
    try {
      final businessId = prefs.getString('businessId');
      final business = await fetchBusiness(businessId);
      viewModel = new PurchaseAssetsVM(context, business);
      return viewModel;
    } catch (Exception) {
      viewModel.logOut(context);
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
    return FutureBuilder(
      future: _createViewModel(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ChangeNotifierProvider(
            create: (context) => viewModel,
            child: Consumer<PurchaseAssetsVM>(
              builder: (_, model, __) {
                return DefaultTabController(
                  length: viewModel.canViewMarketplace ? 4 : 3,
                  child: Scaffold(
                      backgroundColor: CustomColors.colorPrimaryBlue,
                      appBar: AppBar(
                        title: Text(
                          "Purchase Assets",
                          style: TextStyle(fontSize: 30),
                        ),
                        backgroundColor: CustomColors.colorPrimaryBlueAccent,
                        bottom: TabBar(labelPadding: EdgeInsets.all(0), tabs: [
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
                          if (viewModel.canViewMarketplace)
                            Tab(
                                icon: Icon(MdiIcons.store),
                                text: "Marketplace",
                                iconMargin: EdgeInsets.only(bottom: 5.0)),
                        ]),
                      ),
                      drawer: Drawer(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: <Widget>[
                            DrawerHeader(
                                child: SizedBox(),
                                decoration: BoxDecoration(
                                    color: CustomColors.colorPrimaryBlue)),
                            ListTile(
                              title: Text('Log out'),
                              onTap: () {
                                setState(() {
                                  viewModel.logOut(context);
                                });
                              },
                            ),
                            ListTile(
                              title: Text('Discord'),
                              onTap: () {
                                setState(() async {
                                  await canLaunch("https://discord.gg/A8zFrau")
                                      ? await launch(
                                          "https://discord.gg/A8zFrau")
                                      : throw 'Could not launch discord';
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      body: Center(
                        child: TabBarView(children: [
                          Column(
                            children: <Widget>[
                              BusinessInfo(
                                viewModel: this.viewModel,
                                infoType: BusinessInfoType.cashPerSecond,
                              ),
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
                              BusinessInfo(
                                viewModel: this.viewModel,
                                infoType: BusinessInfoType.items,
                              ),
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
                              BusinessInfo(
                                viewModel: this.viewModel,
                                infoType: BusinessInfoType.realEstate,
                              ),
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
                          ),
                          if (viewModel.canViewMarketplace)
                            Column(
                              children: <Widget>[
                                BusinessInfo(
                                  viewModel: this.viewModel,
                                  infoType: BusinessInfoType.cashPerSecond,
                                ),
                                FutureBuilder(
                                  future: _getPurchasableCards("4"),
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
                      )),
                );
              },
            ),
          );
        }
        return Scaffold(
          backgroundColor: CustomColors.colorPrimaryBlue,
          appBar: AppBar(
              title: Text("Purchase Assets"),
              backgroundColor: CustomColors.colorPrimaryBlueAccent),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
