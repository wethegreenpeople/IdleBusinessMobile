import 'package:firebase_analytics/observer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Views/Login/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Helpers/LifeCycleHelper.dart';
import 'Services/FireBase.dart';
import 'Stores/BusinessStore.dart';
import 'Views/Messages/Messages.dart';
import 'Views/PurchaseAssets/CustomColors.dart';
import 'Views/PurchaseAssets/PurchaseAssets.dart';
import 'package:sizer/sizer.dart';
import 'Views/BusinessDirectory/Directory.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalyticsObserver firebaseObserver =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(builder: (context, orientation) {
          SizerUtil().init(constraints, orientation);
          return MaterialApp(
            title: 'IdleBusiness',
            navigatorObservers: [firebaseObserver],
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

    WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(resumeCallBack: () async => setState(() {})));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return PersistentTabView(
      context,
      controller: controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: CustomColors.colorPrimaryBlueAccent,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset:
          false, // This needs to be true if you want to move up the screen when keyboard appears.
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties(
        // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation(
        // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle:
          NavBarStyle.style10, // Choose the nav bar style with this property.
    );
  }

  List<Widget> _buildScreens() {
    return [
      PurchaseAssets(),
      DirectoryPage(),
      MessagesPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
          icon: Icon(Icons.attach_money),
          title: ("Purchase"),
          activeColorPrimary: CustomColors.colorPrimaryButton,
          activeColorSecondary: CustomColors.colorPrimaryWhite,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.menu_book),
          title: ("Directory"),
          activeColorPrimary: CustomColors.colorPrimaryButton,
          activeColorSecondary: CustomColors.colorPrimaryWhite,
          inactiveColorPrimary: Colors.grey),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.email),
          title: ("Messages"),
          activeColorPrimary: CustomColors.colorPrimaryButton,
          activeColorSecondary: CustomColors.colorPrimaryWhite,
          inactiveColorPrimary: Colors.grey),
    ];
  }
}
