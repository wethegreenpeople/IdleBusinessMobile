import 'package:flutter/cupertino.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Views/Business/Business.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class DirectoryVM {
  var searchForBusinessController = TextEditingController();

  Future<Business> searchForBusiness(String businessName) async {
    try {
      final business = await fetchBusinessByName(businessName);
      return business;
    } catch (Exception) {
      return null;
    }
  }

  Future<List<Business>> getRandomBusinesses() async {
    try {
      final businesses = await fetchRandomBusinesses();
      return businesses;
    } catch (Exception) {
      return null;
    }
  }

  void navigateToBusiness(BuildContext context, int businessId) async {
    await pushNewScreen(
      context,
      screen: BusinessPage(businessId),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
