import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:idlebusiness_mobile/Helpers/AuthHelper.dart';
import 'package:idlebusiness_mobile/Models/Investment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StoreConfig.dart';

Future<Business> fetchBusiness(String businessId) async {
  bool _certificateCheck(X509Certificate cert, String host, int port) => true;

  http.Client client() {
    var ioClient = new HttpClient()..badCertificateCallback = _certificateCheck;
    return new IOClient(ioClient);
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    var url = Uri.https(StoreConfig.apiUrl, '/api/business/$businessId');
    final response = await client().get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Business.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      Auth.saveNewToken();
      return fetchBusiness(businessId);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load business');
    }
  } catch (Exception) {
    return null;
  }
}

Future<List<Business>> fetchLeaderboard([bool retry]) async {
  bool _certificateCheck(X509Certificate cert, String host, int port) => true;

  http.Client client() {
    var ioClient = new HttpClient()..badCertificateCallback = _certificateCheck;
    return new IOClient(ioClient);
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    final queryParams = {
      "amountOfResults": "3",
    };
    var url =
        Uri.https(StoreConfig.apiUrl, '/api/business/leaderboard', queryParams);
    final response = await client().get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var businessList = List<Business>();
      var responseJson = json.decode(response.body);
      for (var i = 0; i < 3; ++i) {
        businessList.add(Business.fromJson(responseJson[i]));
      }
      return businessList;
    } else if (response.statusCode == 401) {
      if (!retry) {
        Auth.saveNewToken();
        return fetchLeaderboard(false);
      }
      return fetchLeaderboard(true);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load business');
    }
  } catch (Exception) {
    return null;
  }
}

Future<bool> updateBusinessGains(String businessId) async {
  bool _certificateCheck(X509Certificate cert, String host, int port) => true;

  http.Client client() {
    var ioClient = new HttpClient()..badCertificateCallback = _certificateCheck;
    return new IOClient(ioClient);
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    final queryParams = {
      "businessId": businessId,
    };
    var url =
        Uri.https(StoreConfig.apiUrl, '/api/business/update', queryParams);
    final response = await client().get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return true;
    } else if (response.statusCode == 401) {
      Auth.saveNewToken();
      return updateBusinessGains(businessId);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return false;
    }
  } catch (Exception) {
    return false;
  }
}

// ignore: mixin_inherits_from_not_object
class Business {
  final int id;
  final String name;

  double cashPerSecond;
  double cash;

  double lifeTimeEarnings;
  int amountEmployed;
  int maxEmployeeAmount;
  double espionageChance;
  double espionageDefense;
  int maxItemAmount;
  int amountOwnedItems;
  double businessScore;
  List<Investment> investments;

  Business(
      {this.id,
      this.name,
      double cash,
      double cashPerSecond,
      double lifeTimeEarnings,
      int amountEmployed,
      int maxEmployeeAmount,
      double espionageChance,
      double espionageDefense,
      int maxItemAmount,
      int amountOwnedItems,
      double businessScore,
      List<Investment> investments}) {
    this.cash = cash;
    this.cashPerSecond = cashPerSecond;
    this.lifeTimeEarnings = lifeTimeEarnings;
    this.amountEmployed = amountEmployed;
    this.maxEmployeeAmount = maxEmployeeAmount;
    this.espionageChance = espionageChance;
    this.espionageDefense = espionageDefense;
    this.maxItemAmount = maxItemAmount;
    this.amountOwnedItems = amountOwnedItems;
    this.businessScore = businessScore;
    this.investments = investments;
  }

  factory Business.fromJson(Map<String, dynamic> json) {
    List<Investment> getInvestmentsFromJson(Map<String, dynamic> json) {
      List<Investment> investments = [];
      (json["BusinessInvestments"] as List).forEach((element) async {
        if (element["InvestmentType"] == 10) {
          var investment = Investment();
          investment.investmentAmount =
              element["Investment"]["InvestmentAmount"];
          int investedBusinessId =
              element["Investment"]["BusinessInvestments"][0]["BusinessId"];
          investment.businessInvestedInId = investedBusinessId;
          investments.add(investment);
        }
      });

      return investments;
    }

    return Business(
        id: json['Id'],
        name: json['Name'],
        cash: json['Cash'],
        cashPerSecond: json['CashPerSecond'],
        lifeTimeEarnings: json['LifeTimeEarnings'],
        amountEmployed: json['AmountEmployed'],
        maxEmployeeAmount: json['MaxEmployeeAmount'],
        espionageChance: json['EspionageChance'],
        espionageDefense: json['EspionageDefense'],
        maxItemAmount: json['MaxItemAmount'],
        amountOwnedItems: json['AmountOwnedItems'],
        businessScore: json['BusinessScore'],
        investments: getInvestmentsFromJson(json));
  }

  Future<Business> getBusiness(String businessId) async {
    try {
      final business = await fetchBusiness(businessId);
      return business;
    } catch (Exception) {
      return null;
    }
  }
}
