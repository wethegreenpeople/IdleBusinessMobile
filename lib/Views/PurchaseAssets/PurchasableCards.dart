import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Stores/PurchasableStore.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/PurchaseAssetsVM.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class PurchasableCards extends StatefulWidget {
  final PurchaseAssetsVM viewModel;
  final String purchasableTypeId;

  PurchasableCards({this.viewModel, this.purchasableTypeId});

  @override
  State<StatefulWidget> createState() => _PurchasableCardsState(
        viewModel: viewModel,
        purchasableTypeId: purchasableTypeId,
      );
}

class _PurchasableCardsState extends State<PurchasableCards> {
  Future<List<Purchasable>> futurePurchasables;
  List<Purchasable> purchasables;
  var purchaseAmount = 0;

  final PurchaseAssetsVM viewModel;
  final String purchasableTypeId;

  _PurchasableCardsState({
    this.viewModel,
    this.purchasableTypeId,
  });

  @override
  void initState() {
    super.initState();
    futurePurchasables = fetchPurchasables(
        this.viewModel.business.id.toString(), purchasableTypeId);
    fetchPurchasables(this.viewModel.business.id.toString(), purchasableTypeId)
        .then((value) {
      setState(() {
        purchasables = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateCardStatus() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseAssetsVM>(
        builder: (context, value, child) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: purchasables != null
                    ? cardsFromPurchasableList(purchasables)
                    : SizedBox(),
              ),
            ));
  }

  Widget cardsFromPurchasableList(List<Purchasable> purchasableList) {
    var widgets = new List<Widget>();

    purchasableList.forEach((element) {
      if (isItemVisible(element, purchasableList, this.viewModel.business)) {
        widgets.add(Container(
            width: MediaQuery.of(context).size.width * .5,
            child: Card(
                color: Colors.white,
                child: isItemPurchasable(element, this.viewModel.business)
                    ? clickableCard(element)
                    : unclickableCard(element))));
      }
    });

    // Adding a little empty space at the end to ensure cards don't get stuck behind
    // any nav bars
    widgets.add(SizedBox.fromSize(
      size: Size(0, 10),
    ));

    return ListView(
      children: widgets,
    );
  }

  bool isItemPurchasable(Purchasable purchasable, Business business) {
    if (purchasable.calculateAdjustedCost() > business.cash) return false;
    if (purchasable.isSinglePurchase && purchasable.amountOwnedByBusiness > 0)
      return false;
    if (purchasable.purchasableTypeId == 1 &&
        business.amountEmployed >= business.maxEmployeeAmount) return false;
    if (purchasable.purchasableTypeId == 2 &&
        purchasable.maxItemsMod == 0 &&
        business.amountOwnedItems >= business.maxItemAmount) return false;
    return true;
  }

  bool isItemVisible(Purchasable purchasable, List<Purchasable> allPurchasables,
      Business business) {
    var lifeTimeEarningsUnlocked =
        business.lifeTimeEarnings >= purchasable.unlocksAtTotalEarnings;
    var isUpgradeWithPreviousPurchased = (purchasable.isUpgrade &&
        allPurchasables.any((element) =>
            element.purchasableUpgradeId == purchasable.id &&
            element.amountOwnedByBusiness == 0));
    var alreadyPurchasedUpgrade = (purchasable.purchasableUpgradeId != 0 &&
        purchasable.amountOwnedByBusiness > 0);

    return lifeTimeEarningsUnlocked &&
        !isUpgradeWithPreviousPurchased &&
        !alreadyPurchasedUpgrade;
  }

  Widget clickableCard(Purchasable purchasable) {
    return InkWell(
      onTap: () {
        viewModel.purchaseAsset(purchasable);
      },
      child: cardPurchaseInfo(purchasable),
    );
  }

  Widget unclickableCard(Purchasable purchasable) {
    return Container(
      color: Colors.grey[400],
      child: cardPurchaseInfo(purchasable),
    );
  }
}

ListTile cardPurchaseInfo(Purchasable purchasable) {
  return ListTile(
      title: Text("${purchasable.name} (${purchasable.amountOwnedByBusiness})"),
      subtitle: RichText(
        text: TextSpan(style: TextStyle(color: Colors.blueGrey), children: [
          TextSpan(
              style: TextStyle(fontSize: 12),
              text: purchasable.description == null ||
                      purchasable.description == ""
                  ? null
                  : "${purchasable.description}\n"),
          ...?cashSpan(purchasable),
          ...?cardBonusSpan(
              purchasable.cashPerSecondMod,
              Icons.schedule,
              TextSpan(
                  text: NumberFormat.compactSimpleCurrency()
                      .format(purchasable.cashPerSecondMod))),
          ...?cardBonusSpan(
              purchasable.maxEmployeeMod.toDouble(),
              Icons.face,
              TextSpan(
                  text: NumberFormat.compact()
                      .format(purchasable.maxEmployeeMod))),
          ...?cardBonusSpan(
              purchasable.espionageChanceMod.toDouble(),
              MdiIcons.sword,
              TextSpan(
                  text: NumberFormat.percentPattern()
                      .format(purchasable.espionageChanceMod))),
          ...?cardBonusSpan(
              purchasable.espionageDefenseMod.toDouble(),
              MdiIcons.shieldOutline,
              TextSpan(
                  text: NumberFormat.percentPattern()
                      .format(purchasable.espionageDefenseMod))),
          ...?cardBonusSpan(
              purchasable.maxItemsMod.toDouble(),
              Icons.business_center,
              TextSpan(
                  text:
                      NumberFormat.compact().format(purchasable.maxItemsMod))),
          ...?cardBonusSpan((purchasable.isGlobalPurchase ? 1 : 0).toDouble(),
              MdiIcons.earth, TextSpan(text: "")),
        ]),
      ));
}

List<InlineSpan> cardBonusSpan(
    double purchasableStat, IconData icon, TextSpan textSpan) {
  if (purchasableStat != 0) {
    var spanList = List<InlineSpan>();
    spanList.add(WidgetSpan(
        child: Container(
      margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
      child: Icon(
        icon,
        size: 18,
      ),
    )));
    spanList.add(textSpan);

    return spanList;
  }

  return null;
}

List<InlineSpan> cashSpan(Purchasable purchasable) {
  if (purchasable.cost != 0) {
    var spanList = List<InlineSpan>();
    spanList.add(WidgetSpan(
        child: Icon(
      Icons.attach_money,
      size: 18,
    )));
    spanList.add(TextSpan(
        text: NumberFormat.compactSimpleCurrency()
            .format(purchasable.calculateAdjustedCost())));

    return spanList;
  }

  return null;
}
