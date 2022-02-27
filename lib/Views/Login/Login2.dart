import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:idlebusiness_mobile/Helpers/AuthHelper.dart' as AuthHelper;
import 'package:idlebusiness_mobile/Views/PurchaseAssets/CustomColors.dart';
import '../../main.dart';

const users = const {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String> _authUser(LoginData data) async {
    var success = await AuthHelper.Auth().signIn(data.name, data.password);
    if (success) {
      return null;
    } else {
      return 'Invalid credentials';
    }
  }

  Future<String> _signupUser(SignupData data) async {
    var businessName = data.additionalSignupData["businessName"];
    var response = await AuthHelper.Auth()
        .signUp(data.name, data.password, true, businessName);

    if (response == "true") return null;
    return response;
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Idle Business',
      logo: const AssetImage('assets/images/icon_transparent.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      additionalSignupFields: [
        UserFormField(keyName: "businessName", displayName: "Business Name")
      ],
      theme: LoginTheme(
        primaryColor: Color.fromARGB(255, 113, 178, 207),
        accentColor: Colors.black,
        buttonStyle: TextStyle(color: Colors.black),
      ),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MyHomePage(title: 'Purchase Assets'),
        ));
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
