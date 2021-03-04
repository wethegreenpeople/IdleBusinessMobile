import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:idlebusiness_mobile/Helpers/AppHelper.dart';
import 'package:http/io_client.dart';
import 'package:idlebusiness_mobile/Stores/StoreConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseAuth {
  Future<bool> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  void signOut();
}

class Auth extends BaseAuth {
  void _setLoginState(bool isSignedIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSignedIn', isSignedIn);
  }

  void _saveBusinessId(String businessId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('businessId', businessId);
  }

  static void saveNewToken() async {
    bool _certificateCheck(X509Certificate cert, String host, int port) => true;

    http.Client client() {
      var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
      return new IOClient(ioClient);
    }

    var apikey =
        json.decode(await AppHelper().getSecrets())['apiKey'].toString();
    var queryParameters = {
      'apiKey': apikey,
    };
    var url =
        Uri.https(StoreConfig.apiUrl, '/api/auth/gettoken', queryParameters);
    final response = await client().get(url);

    if (response.statusCode == 200) {
      var token = response.body;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
    }
  }

  Future<bool> createGuestAccount() async {
    bool _certificateCheck(X509Certificate cert, String host, int port) => true;

    http.Client client() {
      var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
      return new IOClient(ioClient);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");

      var url = Uri.https(StoreConfig.apiUrl, '/api/auth/createguest');
      final response = await client().get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        _setLoginState(true);
        _saveBusinessId(json.decode(response.body)['Id'].toString());
        return true;
      } else if (response.statusCode == 401) {
        saveNewToken();
        await this.createGuestAccount();
        return true;
      } else {
        _setLoginState(false);
        return false;
      }
    } catch (Exception) {
      saveNewToken();
      return false;
    }
  }

  @override
  Future<bool> signIn(String email, String password,
      [bool firstTry = true]) async {
    bool _certificateCheck(X509Certificate cert, String host, int port) => true;

    http.Client client() {
      var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
      return new IOClient(ioClient);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");

      var queryParameters = {'token': token};

      var url =
          Uri.https(StoreConfig.apiUrl, '/api/auth/login', queryParameters);
      final response = await client().post(url, headers: {
        "Authorization":
            "Basic " + base64Encode(utf8.encode('$email:$password')),
      });

      if (response.statusCode == 200) {
        _setLoginState(true);
        _saveBusinessId(json.decode(response.body)['Id'].toString());
        return true;
      } else if (response.statusCode == 401 && firstTry) {
        saveNewToken();
        await this.signIn(email, password, false);
        return false;
      } else {
        _setLoginState(false);
        return false;
      }
    } catch (Exception) {
      saveNewToken();
    }

    return false;
  }

  @override
  void signOut() {
    _setLoginState(false);
  }

  @override
  Future<String> signUp(String email, String password,
      [bool firstTry = true, String businessName]) async {
    bool _certificateCheck(X509Certificate cert, String host, int port) => true;

    http.Client client() {
      var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
      return new IOClient(ioClient);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");

      var queryParameters = {
        'token': token,
        'businessName': businessName,
      };

      var url =
          Uri.https(StoreConfig.apiUrl, '/api/auth/register', queryParameters);
      final response = await client().post(url, headers: {
        "Authorization":
            "Basic " + base64Encode(utf8.encode('$email:$password')),
      });

      if (response.statusCode == 200) {
        _setLoginState(true);
        _saveBusinessId(json.decode(response.body)['Id'].toString());
        return "true";
      } else if (response.statusCode == 401 && firstTry) {
        saveNewToken();
        await this.signIn(email, password, false);
        return "false";
      } else {
        _setLoginState(false);
        return "false";
      }
    } catch (Exception) {
      saveNewToken();
    }

    return "false";
  }
}
