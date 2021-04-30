import 'package:flutter/cupertino.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Views/Business/Business.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class DirectoryVM extends ChangeNotifier {
  var searchForBusinessController = TextEditingController();

  Business _currentBusiness;
  Business get currentBusiness {
    return _currentBusiness;
  }

  set currentBusiness(Business value) {
    _currentBusiness = value;
    notifyListeners();
  }

  Future<Business> updateCurrentBusiness() async {
    return await fetchBusiness(currentBusiness.id.toString());
  }

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

  void navigateToBusiness(
      BuildContext context, int viewingBusinessId, int viewedBusinessId) async {
    await pushNewScreen(
      context,
      screen: BusinessPage(viewingBusinessId, viewedBusinessId),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
