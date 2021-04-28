import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:idlebusiness_mobile/Helpers/AuthHelper.dart';
import 'package:idlebusiness_mobile/Models/ApiResponse.dart';
import 'package:idlebusiness_mobile/Models/Investment.dart';
import 'package:idlebusiness_mobile/Models/Message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'StoreConfig.dart';

class BusinessStore {
  Future<ApiResponse> joinBusinessSector(int businessId, int sectorId,
      {bool retry}) async {
    bool _certificateCheck(X509Certificate cert, String host, int port) => true;

    http.Client client() {
      var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
      return new IOClient(ioClient);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");

      final queryParams = {
        "businessId": businessId.toString(),
        "sectorId": sectorId.toString(),
      };
      var url = Uri.https(
          StoreConfig.apiUrl, '/api/business/joinsector', queryParams);
      final response = await client().post(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return ApiResponse(true, "");
      } else if (response.statusCode == 401 && retry) {
        Auth.saveNewToken();
        return joinBusinessSector(businessId, sectorId, retry: false);
      } else {
        return ApiResponse(false, response.body);
      }
    } catch (Exception) {
      return null;
    }
  }

  Future<ApiResponse> investInBusiness(
      int investingBusinessId, int investedBusinessId, double investmentAmount,
      {bool retry}) async {
    bool _certificateCheck(X509Certificate cert, String host, int port) => true;

    http.Client client() {
      var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
      return new IOClient(ioClient);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");

      final queryParams = {
        "investingBusinessId": investingBusinessId.toString(),
        "investedBusinessId": investedBusinessId.toString(),
        "investmentAmount": investmentAmount.toString(),
      };
      var url =
          Uri.https(StoreConfig.apiUrl, '/api/business/invest', queryParams);
      final response = await client().post(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return ApiResponse(true, "");
      } else if (response.statusCode == 401 && retry) {
        Auth.saveNewToken();
        return investInBusiness(
            investingBusinessId, investedBusinessId, investmentAmount,
            retry: false);
      } else {
        return ApiResponse(false, response.body);
      }
    } catch (Exception) {
      return null;
    }
  }

  Future<ApiResponse> espionageBusiness(
      int attackingBusinessId, int defendingBusinessId,
      {bool retry}) async {
    bool _certificateCheck(X509Certificate cert, String host, int port) => true;

    http.Client client() {
      var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
      return new IOClient(ioClient);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");

      final queryParams = {
        "attackingBusinessId": attackingBusinessId.toString(),
        "defendingBusinessId": defendingBusinessId.toString(),
      };
      var url =
          Uri.https(StoreConfig.apiUrl, '/api/business/espionage', queryParams);
      final response = await client().post(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        if (response.body == "Unsuccessful Espionage")
          return ApiResponse(false, "Failed to espionage business");
        return ApiResponse(true, "");
      } else if (response.statusCode == 401 && retry) {
        Auth.saveNewToken();
        return espionageBusiness(attackingBusinessId, defendingBusinessId,
            retry: false);
      } else {
        return ApiResponse(false, response.body);
      }
    } catch (Exception) {
      return null;
    }
  }

  Future<ApiResponse> attemptTheftOnBusiness(
      int attackingBusinessId, int defendingBusinessId,
      {bool retry}) async {
    bool _certificateCheck(X509Certificate cert, String host, int port) => true;

    http.Client client() {
      var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
      return new IOClient(ioClient);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");

      final queryParams = {
        "attackingBusinessId": attackingBusinessId.toString(),
        "defendingBusinessId": defendingBusinessId.toString(),
      };
      var url =
          Uri.https(StoreConfig.apiUrl, '/api/business/theft', queryParams);
      final response = await client().post(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        if (response.body == "Unsuccessful Theft")
          return ApiResponse(false, "Failed to espionage business");
        return ApiResponse(true, response.body);
      } else if (response.statusCode == 401 && retry) {
        Auth.saveNewToken();
        return attemptTheftOnBusiness(attackingBusinessId, defendingBusinessId,
            retry: false);
      } else {
        return ApiResponse(false, response.body);
      }
    } catch (Exception) {
      return null;
    }
  }
}

Future<Business> fetchBusiness(String businessId) async {
  bool _certificateCheck(X509Certificate cert, String host, int port) => true;

  http.Client client() {
    var ioClient = new HttpClient()..badCertificateCallback = _certificateCheck;
    return new IOClient(ioClient);
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    await updateBusinessGains(businessId);

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

Future<Business> fetchBusinessByName(String businessName) async {
  bool _certificateCheck(X509Certificate cert, String host, int port) => true;

  http.Client client() {
    var ioClient = new HttpClient()..badCertificateCallback = _certificateCheck;
    return new IOClient(ioClient);
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    final queryParams = {
      "businessName": businessName,
    };
    var url = Uri.https(
        StoreConfig.apiUrl, '/api/business/businessbyname', queryParams);
    final response = await client().get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      return Business.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      Auth.saveNewToken();
      return fetchBusinessByName(businessName);
    } else {
      return null;
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
      var businessList = <Business>[];
      var responseJson = json.decode(response.body);
      for (var i = 0; i < 3; ++i) {
        businessList.add(Business.fromJson(responseJson[i]));
      }
      return businessList;
    } else if (response.statusCode == 401) {
      if (retry) {
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

Future<List<Business>> fetchRandomBusinesses([bool retry]) async {
  bool _certificateCheck(X509Certificate cert, String host, int port) => true;

  http.Client client() {
    var ioClient = new HttpClient()..badCertificateCallback = _certificateCheck;
    return new IOClient(ioClient);
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var amountOfResults = 3;

    final queryParams = {
      "amountOfBusinesses": amountOfResults.toString(),
    };
    var url = Uri.https(
        StoreConfig.apiUrl, '/api/business/randombusiness', queryParams);
    final response = await client().get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      var businessList = <Business>[];
      var responseJson = json.decode(response.body);
      for (var i = 0; i < amountOfResults; ++i) {
        var business = Business.fromJson(responseJson[i]);
        if (business.name != null || business.name != "null")
          businessList.add(business);
      }
      return businessList;
    } else if (response.statusCode == 401) {
      if (retry) {
        Auth.saveNewToken();
        return fetchRandomBusinesses(false);
      }
      return null;
    } else {
      throw Exception('Failed to load business');
    }
  } catch (Exception) {
    return null;
  }
}

Future<List<Message>> fetchMessages(String businessId, [bool retry]) async {
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
      "amountOfResults": "30",
    };
    var url =
        Uri.https(StoreConfig.apiUrl, '/api/business/messages', queryParams);
    final response = await client().get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      List<Message> messagesList = [];
      var responseJson = json.decode(response.body);
      (responseJson as List).forEach((element) {
        messagesList.add(Message.fromJson(element));
      });
      return messagesList;
    } else if (response.statusCode == 401) {
      if (retry) {
        Auth.saveNewToken();
        return fetchMessages(businessId, false);
      }
      throw Exception('Failed to load messages');
    } else {
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
  double espionageCost;
  List<Investment> investments;
  List<Investment> espionages;
  int sectorId;

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
      double espionageCost,
      List<Investment> investments,
      List<Investment> espionages,
      int sectorId}) {
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
    this.espionageCost = espionageCost;
    this.investments = investments;
    this.espionages = espionages;
    this.sectorId = sectorId;
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
          int investmentDirection = element["Investment"]["BusinessInvestments"]
              [0]["InvestmentDirection"];
          investment.businessInvestedInId = investedBusinessId;
          investment.investmentDirection = investmentDirection;
          investments.add(investment);
        }
      });

      return investments;
    }

    List<Investment> getEspionagesFromJson(Map<String, dynamic> json) {
      List<Investment> investments = [];
      (json["BusinessInvestments"] as List).forEach((element) async {
        if (element["InvestmentType"] == 20) {
          var investment = Investment();
          investment.investmentAmount =
              element["Investment"]["InvestmentAmount"];
          int investedBusinessId =
              element["Investment"]["BusinessInvestments"][0]["BusinessId"];
          int investmentDirection = element["Investment"]["BusinessInvestments"]
              [0]["InvestmentDirection"];
          investment.businessInvestedInId = investedBusinessId;
          investment.investmentDirection = investmentDirection;
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
        espionageCost: json['EspionageCost'],
        sectorId: json['Sector'] != null ? json['Sector']['Id'] : null,
        investments: getInvestmentsFromJson(json),
        espionages: getEspionagesFromJson(json));
  }

  Future<Business> getBusiness(String businessId) async {
    try {
      final business = await fetchBusiness(businessId);
      return business;
    } catch (Exception) {
      return null;
    }
  }

  Future<List<Message>> getBusinessMessages(String businessId) async {
    try {
      final List<Message> messages = await fetchMessages(businessId, true);
      return messages;
    } catch (Exception) {
      return null;
    }
  }
}
