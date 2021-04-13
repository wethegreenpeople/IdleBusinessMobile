import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Models/Message.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/CustomColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'MessagesVM.dart';
import 'package:sizer/sizer.dart';

class MessagesPage extends StatefulWidget {
  MessagesPage();

  @override
  State<StatefulWidget> createState() => new _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  var viewModel = MessagesVM();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: CustomColors.colorPrimaryBlueAccent,
        title: new Text("Messages"),
      ),
      backgroundColor: CustomColors.colorPrimaryBlue,
      body: Center(
        child: FutureBuilder<List<Message>>(
            future: viewModel.getMessagesForCurrentBusiness(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SingleChildScrollView(
                                child: Container(
                                  height: 78.0.h,
                                  child: RefreshIndicator(
                                    onRefresh: () async {
                                      setState(() {});
                                      return;
                                    },
                                    child: ListView(
                                      children: [
                                        ...messagesCards(snapshot.data)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
              return CircularProgressIndicator();
            }),
      ),
    );
  }

  List<Widget> messagesCards(List<Message> messages) {
    List<Widget> widgets = [];

    messages.forEach((element) {
      widgets.add(Row(
        children: [
          Expanded(
            child: Card(
                child: ListTile(
              leading: element.read
                  ? Icon(MdiIcons.email)
                  : Icon(MdiIcons.emailOpen),
              title: Text(element.messageBody),
            )),
          ),
        ],
      ));
    });

    return widgets;
  }
}
