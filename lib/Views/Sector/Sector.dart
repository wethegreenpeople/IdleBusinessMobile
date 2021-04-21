import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/CustomColors.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/PurchaseAssets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:sizer/sizer.dart';

class SectorPage extends StatefulWidget {
  Business _business;
  SectorPage(this._business);

  @override
  State<StatefulWidget> createState() => new _SectorPageState(_business);
}

class _SectorPageState extends State<SectorPage> {
  Business _business;
  _SectorPageState(this._business);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: CustomColors.colorPrimaryBlueAccent,
        title: new Text("Join a sector!"),
      ),
      backgroundColor: CustomColors.colorPrimaryBlue,
      body: Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Card(
                        color: Colors.white,
                        child: ListTile(
                            leading: Icon(Icons.info),
                            title: Text("Joining a sector"),
                            subtitle: RichText(
                                text: TextSpan(
                              children: [
                                TextSpan(
                                    style: TextStyle(color: Colors.grey),
                                    text:
                                        "In addition to gaining the bonuses listed below each sector, once you join a sector you will belong to a group of businesses that can choose to help each other out. \n\nAfter joining a sector you will unlock bonus items whose stats are applied to ALL businesses within that sector.\n\nIf you see the globe icon ("),
                                WidgetSpan(
                                    child: Icon(
                                  MdiIcons.earth,
                                  size: 20,
                                )),
                                TextSpan(
                                    style: TextStyle(color: Colors.grey),
                                    text:
                                        "), the bonus will be applied to all businesses within your sector"),
                              ],
                            )))),
                    _sectorCard("Tech", "-10% Item Cost For All Items",
                        Icon(Icons.computer), _business.id, 1),
                    _sectorCard(
                        "Marketing",
                        "-10% Employee Cost For All Employees",
                        Icon(Icons.perm_media),
                        _business.id,
                        3),
                    _sectorCard(
                        "Real Estate",
                        "No Cash Per Second fee on real estate",
                        Icon(Icons.house),
                        _business.id,
                        2),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectorCard(String sectorTitle, String sectorBonusText,
      Icon leadingIcon, int businessId, int sectorId) {
    return Card(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: leadingIcon,
              title: Text(sectorTitle),
              subtitle: Text(sectorBonusText),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(
                    'JOIN SECTOR',
                    style: TextStyle(color: CustomColors.colorPrimaryButton),
                  ),
                  onPressed: () async {
                    var response = await BusinessStore()
                        .joinBusinessSector(businessId, sectorId);
                    if (!response.success) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text(':('),
                                content: Text(response.returnValue),
                              ));
                    } else if (response.success) {
                      _pushPurchaseAssetsScreen(context);
                    }
                  },
                )
              ],
            )
          ],
        ));
  }

  Future<void> _pushPurchaseAssetsScreen(BuildContext context) async {
    await pushNewScreen(
      context,
      screen: PurchaseAssets(),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }
}
