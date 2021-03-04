import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Views/Login/Login.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/BusinessInfo.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/PurchasableCards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Stores/BusinessStore.dart';
import 'Views/PurchaseAssets/CustomColors.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';
import 'Views/BusinessDirectory/Directory.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(builder: (context, orientation) {
          SizerUtil().init(constraints, orientation);
          return MaterialApp(
            title: 'IdleBusiness',
            theme: ThemeData(
              primarySwatch: CustomColors.colorPrimaryBlueAccent,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              primaryColor: CustomColors.colorPrimaryBlue,
              accentColor: CustomColors.colorPrimaryBlueAccent,

              // Define the default TextTheme. Use this to specify the default
              // text styling for headlines, titles, bodies of text, and more.
              textTheme: TextTheme(
                headline1:
                    TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
                headline6:
                    TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
                bodyText1: TextStyle(fontSize: 21.0, fontFamily: 'Hind'),
                bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
              ),
            ),
            home: FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data?.getBool('isSignedIn') ?? false)
                      return MyHomePage(
                        title: 'Purchase Assets',
                      );
                  }
                  return LoginPage();
                }),
          );
        });
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({this.business});

  Business business = Business();
  Widget businessInfo;
  int index;
  PersistentTabController controller = PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
    index = 0;

    _getBusiness().then((value) {
      setState(() {
        this.business = value;
        this.business.addListener(() {
          updateViews();
        });
      });
    });

    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.resumed.toString()) {
        setState(() {});
      }
    });
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
      businessInfo = new BusinessInfo(
        business: business,
      );
      return business;
    } catch (Exception) {
      return null;
    }
  }

  Future<Widget> _getPurchasableCards(String purchasableTypeId) async {
    try {
      return PurchasableCards(
        business: business,
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          bottomNavigationBar: new BottomNavigationBar(
              currentIndex: this.index,
              onTap: (int index) {
                setState(() {
                  if (this.index == index) return;
                  this.index = index;
                  switch (this.index) {
                    case 0:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyHomePage(title: 'Purchase Assets')));
                      break;
                    case 1:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DirectoryPage()));
                      break;
                    default:
                      MyHomePage(title: 'Purchase Assets');
                      break;
                  }
                });
              },
              items: <BottomNavigationBarItem>[
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.attach_money),
                  label: "Purchase Assets",
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.menu_book),
                  label: "Business Directory",
                ),
                new BottomNavigationBarItem(
                  icon: new Icon(Icons.mail),
                  label: "Messages",
                ),
              ]),
          backgroundColor: CustomColors.colorPrimaryBlue,
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
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
                  title: Text('Purchase Assets'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Business Directory'),
                  onTap: () {},
                ),
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

                      _setLoginState();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
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
                  business != null ? businessInfo : SizedBox(),
                  if (business != null)
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
                  BusinessInfo(business: business),
                  if (business != null)
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
                  BusinessInfo(business: business),
                  if (business != null)
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
          )),
    );
  }

  List<Widget> _buildScreens() {
    return [
      MyHomePage(
        title: 'Purchase Assets',
      ),
      DirectoryPage()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: ("Home"),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings),
        title: ("Settings"),
      ),
    ];
  }
}
