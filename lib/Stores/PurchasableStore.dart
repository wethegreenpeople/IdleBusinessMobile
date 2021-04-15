import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:idlebusiness_mobile/Helpers/AuthHelper.dart';
import 'package:idlebusiness_mobile/Models/BusinessPurchase.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Stores/StoreConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchasableStore {
  Future<BusinessPurchase> purchaseItem(
      String businessId, String purchasableId, String purchaseAmount) async {
    bool _certificateCheck(X509Certificate cert, String host, int port) => true;

    http.Client client() {
      var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
      return new IOClient(ioClient);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final queryParams = {
        "businessId": businessId,
        "purchasableId": purchasableId,
        "purchaseAmount": purchaseAmount,
      };

      final url = Uri.https(
          StoreConfig.apiUrl, '/api/purchasable/purchaseItem', queryParams);

      final response = await client().get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        return Purchasable.fromPurchaseResponse(json.decode(response.body));
      } else if (response.statusCode == 401) {
        Auth.saveNewToken();
        return purchaseItem(businessId, purchasableId, purchaseAmount);
      } else {
        return null;
      }
    } catch (Exception) {
      return null;
    }
  }
}

Future<List<Purchasable>> fetchPurchasables(
    String businessId, String purchasableTypeId) async {
  bool _certificateCheck(X509Certificate cert, String host, int port) => true;

  http.Client client() {
    var ioClient = new HttpClient()..badCertificateCallback = _certificateCheck;
    return new IOClient(ioClient);
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final queryParams = {
      "businessId": businessId,
      "purchasableTypeId": purchasableTypeId
    };

    final url = Uri.https(
        StoreConfig.apiUrl, '/api/purchasable/getpurchase', queryParams);

    final response = await client().get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Purchasable.fromJsonList(json.decode(response.body));
    } else if (response.statusCode == 401) {
      Auth.saveNewToken();
      return fetchPurchasables(businessId, purchasableTypeId);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load business');
    }
  } catch (Exception) {
    return null;
  }
}

class Purchasable {
  final int id;
  final String name;
  double cost;
  final double cashPerSecondMod;
  int amountOwnedByBusiness;
  final double perOwnedMod;
  int maxEmployeeMod;
  double espionageChanceMod;
  double espionageDefenseMod;
  int maxItemsMod;
  double unlocksAtTotalEarnings;
  int purchasableTypeId;
  String description;
  bool isSinglePurchase;
  bool isGlobalPurchase;
  bool isUpgrade;
  int purchasableUpgradeId;

  Purchasable(
      {this.id,
      this.name,
      this.cost,
      this.cashPerSecondMod,
      this.amountOwnedByBusiness,
      this.perOwnedMod,
      this.maxEmployeeMod,
      this.espionageChanceMod,
      this.espionageDefenseMod,
      this.maxItemsMod,
      this.unlocksAtTotalEarnings,
      this.purchasableTypeId,
      this.description,
      this.isSinglePurchase,
      this.isGlobalPurchase,
      this.isUpgrade,
      this.purchasableUpgradeId});

  double calculateAdjustedCost() {
    return cost * pow((1 + perOwnedMod), amountOwnedByBusiness);
  }

  static Purchasable fromJson(dynamic json) {
    return Purchasable(
        id: json['Purchasable']['Id'],
        name: json['Purchasable']['Name'],
        cost: json['Purchasable']['Cost'],
        cashPerSecondMod: json['Purchasable']['CashModifier'],
        perOwnedMod: json['Purchasable']['PerOwnedModifier'],
        maxEmployeeMod: json['Purchasable']['MaxEmployeeModifier'],
        espionageChanceMod: json['Purchasable']['EspionageModifier'],
        espionageDefenseMod: json['Purchasable']['EspionageDefenseModifier'],
        maxItemsMod: json['Purchasable']['MaxItemAmountModifier'],
        unlocksAtTotalEarnings: json['Purchasable']['UnlocksAtTotalEarnings'],
        amountOwnedByBusiness: json['AmountOfPurchases'],
        purchasableTypeId: json['Purchasable']['PurchasableTypeId'],
        description: json['Purchasable']['Description'],
        isSinglePurchase: json['Purchasable']['IsSinglePurchase'],
        isGlobalPurchase: json['Purchasable']['IsGlobalPurchase'],
        isUpgrade: json['Purchasable']['IsUpgrade'],
        purchasableUpgradeId: json['Purchasable']['PurchasableUpgradeId']);
  }

  static BusinessPurchase fromPurchaseResponse(dynamic json) {
    var purchase = fromJson(json);
    purchase.amountOwnedByBusiness = json['TotalOwned'];
    var business = Business.fromJson(json['Business']);
    return BusinessPurchase(purchasable: purchase, business: business);
  }

  static List<Purchasable> fromJsonList(List<dynamic> jsonObjects) {
    var purchasableList = new List<Purchasable>();

    jsonObjects.forEach((element) {
      purchasableList.add(fromJson(element));
    });
    return purchasableList;
  }
}
