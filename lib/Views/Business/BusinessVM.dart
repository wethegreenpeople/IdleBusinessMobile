import 'package:idlebusiness_mobile/Models/ApiResponse.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Stores/PurchasableStore.dart';
import 'package:intl/intl.dart';

class BusinessVM {
  Business _viewingBusiness;
  Business _viewedBusiness;
  int _viewedBusinessId;
  int _viewingBusinessId;
  List<Purchasable> _viewingBusinessPurchasablesItems;

  String get viewedBusinessName {
    return _viewedBusiness.name;
  }

  String get viewingBusinessEspionageCost {
    return NumberFormat.compact()
        .format(_viewingBusiness.espionageCost)
        .toString();
  }

  bool get viewingOwnBusiness {
    return _viewingBusinessId == _viewedBusinessId;
  }

  bool get canViewInvestments {
    return viewingOwnBusiness ||
        _viewingBusinessPurchasablesItems.any(
            (element) => element.id == 28 && element.amountOwnedByBusiness > 0);
  }

  bool get canViewEspionages {
    return viewingOwnBusiness ||
        _viewingBusinessPurchasablesItems.any(
            (element) => element.id == 32 && element.amountOwnedByBusiness > 0);
  }

  BusinessVM(int viewingBusinessId, int viewedBusinessId) {
    _viewedBusinessId = viewedBusinessId;
    _viewingBusinessId = viewingBusinessId;
    _getViewingAndViewedBusinesses(viewedBusinessId, viewingBusinessId);
    _getViewingBusinessPurchases(viewingBusinessId);
  }

  Future<void> _getViewingAndViewedBusinesses(
      int viewedBusinessId, int viewingBusinessId) async {
    await getBusiness(viewingBusinessId)
        .then((value) => _viewingBusiness = value);
    await getBusiness(viewedBusinessId)
        .then((value) => _viewedBusiness = value);
  }

  Future<void> _getViewingBusinessPurchases(int viewingBusinessId) async {
    _viewingBusinessPurchasablesItems =
        await fetchPurchasables(_viewingBusinessId.toString(), "2");
  }

  Future<bool> _ensureBusinessesArePopulated() async {
    var areBusinessesPopulated =
        (_viewedBusiness == null && _viewingBusiness == null);
    if (!areBusinessesPopulated)
      await _getViewingAndViewedBusinesses(
          _viewedBusinessId, _viewedBusinessId);
    return areBusinessesPopulated;
  }

  Future<Business> getBusiness(int businessId) async {
    try {
      if (businessId == _viewingBusiness?.id)
        return _viewingBusiness;
      else if (businessId == _viewedBusiness?.id) return _viewedBusiness;
      final business = await fetchBusiness(businessId.toString());
      return business;
    } catch (Exception) {
      return null;
    }
  }

  Future<ApiResponse> investInBusiness(double investmentAmount) async {
    await _ensureBusinessesArePopulated();
    var response = await BusinessStore().investInBusiness(
        _viewingBusiness.id, _viewedBusiness.id, investmentAmount);
    return response;
  }

  Future<ApiResponse> espionageBusiness() async {
    await _ensureBusinessesArePopulated();
    var response = await BusinessStore()
        .espionageBusiness(_viewingBusiness.id, _viewedBusiness.id);
    return response;
  }

  Future<int> getEspionageSuccessChance() async {
    await _ensureBusinessesArePopulated();
    var successChance = 0;

    successChance =
        ((_viewingBusiness.espionageChance - _viewedBusiness.espionageDefense) *
                100)
            .toInt();
    return successChance;
  }

  Future<int> calculateEspionageLoss() async {
    await _ensureBusinessesArePopulated();

    var result = 0;
    result =
        ((_viewingBusiness.espionageChance - _viewedBusiness.espionageDefense) *
                100)
            .toInt();
    if (result < 0)
      return 0;
    else if (result > 50)
      return 50;
    else
      return result;
  }
}
