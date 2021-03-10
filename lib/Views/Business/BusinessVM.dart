import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';

class BusinessVM {
  BusinessVM(int businessId);

  Future<Business> getBusiness(int businessId) async {
    try {
      final business = await fetchBusiness(businessId.toString());
      return business;
    } catch (Exception) {
      return null;
    }
  }
}
