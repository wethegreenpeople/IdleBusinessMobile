import 'package:flutter/material.dart';
import '../PurchaseAssets/CustomColors.dart';

class DirectoryPage extends StatefulWidget {
  DirectoryPage();

  @override
  State<StatefulWidget> createState() => new _DirectoryPageState();
}

class _DirectoryPageState extends State<DirectoryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Login'),
        ),
        body: Stack(
          children: <Widget>[
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    return Center(child: CircularProgressIndicator());
  }
}
