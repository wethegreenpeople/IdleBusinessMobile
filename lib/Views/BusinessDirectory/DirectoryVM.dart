import 'package:flutter/cupertino.dart';
import 'package:idlebusiness_mobile/Views/Business/Business.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class DirectoryVM {
  void navigateToBusiness(BuildContext context, int businessId) async {
    await pushNewScreen(
      context,
      screen: BusinessPage(businessId),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
