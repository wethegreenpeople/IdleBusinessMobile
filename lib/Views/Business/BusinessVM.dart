import 'package:idlebusiness_mobile/Models/ApiResponse.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessVM {
  Business _viewingBusiness;
  Business _viewedBusiness;
  int _viewedBusinessId;

  String get viewedBusinessName {
    return _viewedBusiness.name;
  }

  String get viewingBusinessEspionageCost {
    return NumberFormat.compact()
        .format(_viewingBusiness.espionageCost)
        .toString();
  }

  BusinessVM(int viewedBusinessId) {
    _viewedBusinessId = viewedBusinessId;
    _getViewingAndViewedBusinesses(viewedBusinessId);
  }

  Future<void> _getViewingAndViewedBusinesses(int viewedBusinessId) async {
    var viewingBusinessId = 0;
    await SharedPreferences.getInstance().then((value) =>
        viewingBusinessId = int.parse(value.getString('businessId')));
    await getBusiness(viewingBusinessId)
        .then((value) => _viewingBusiness = value);
    await getBusiness(viewedBusinessId)
        .then((value) => _viewedBusiness = value);
  }

  Future<bool> _ensureBusinessesArePopulated() async {
    var areBusinessesPopulated =
        (_viewedBusiness == null && _viewingBusiness == null);
    if (!areBusinessesPopulated)
      await _getViewingAndViewedBusinesses(_viewedBusinessId);
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
