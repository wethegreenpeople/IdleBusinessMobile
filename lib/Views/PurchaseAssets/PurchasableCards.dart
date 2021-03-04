import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Helpers/AppHelper.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Stores/PurchasableStore.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PurchasableCards extends StatefulWidget {
  final Business business;
  final String purchasableTypeId;

  PurchasableCards({
    this.business,
    this.purchasableTypeId,
  });

  @override
  State<StatefulWidget> createState() => _PurchasableCardsState(
      business: business, purchasableTypeId: purchasableTypeId);
}

class _PurchasableCardsState extends State<PurchasableCards> {
  Future<List<Purchasable>> futurePurchasables;
  List<Purchasable> purchasables;
  var purchaseAmount = 0;
  final purchaseDebouncer = Debouncer(milliseconds: 750);

  Business business;
  final String purchasableTypeId;

  _PurchasableCardsState({
    this.business,
    this.purchasableTypeId,
  });

  @override
  void initState() {
    super.initState();
    this.business.addListener(() {
      updateCardStatus();
    }, ["cash", "lifeTimeEarnings"]);
    futurePurchasables =
        fetchPurchasables(this.business?.id.toString(), purchasableTypeId);
    fetchPurchasables(this.business?.id.toString(), purchasableTypeId)
        .then((value) {
      setState(() {
        purchasables = value;
      });
    });
  }

  @override
  void dispose() {
    this.business.removeListener(() {
      updateCardStatus();
    }, ["cash", "lifeTimeEarnings"]);
    super.dispose();
  }

  void updateCardStatus() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: purchasables != null
            ? cardsFromPurchasableList(purchasables)
            : SizedBox(),
      ),
    );
  }

  Widget cardsFromPurchasableList(List<Purchasable> purchasableList) {
    var widgets = new List<Widget>();

    purchasableList.forEach((element) {
      if (isItemVisible(element, this.business)) {
        widgets.add(Container(
            width: MediaQuery.of(context).size.width * .5,
            child: Card(
                color: Colors.white,
                child: isItemPurchasable(element, this.business)
                    ? clickableCard(element)
                    : unclickableCard(element))));
      }
    });

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

  bool isItemVisible(Purchasable purchasable, Business business) {
    return business.lifeTimeEarnings >= purchasable.unlocksAtTotalEarnings;
  }

  Widget clickableCard(Purchasable purchasable) {
    return InkWell(
      onTap: () {
        purchaseAmount++;

        // "fake" stats updates. Update stats immediately for the user's enjoyment
        this.business.cash -= purchasable.calculateAdjustedCost();
        this.business.cashPerSecond += purchasable.cashPerSecondMod;
        this.business.maxItemAmount += purchasable.maxItemsMod;
        this.business.maxEmployeeAmount += purchasable.maxEmployeeMod;
        this.business.espionageChance += purchasable.espionageChanceMod;
        this.business.espionageDefense += purchasable.espionageDefenseMod;
        if (purchasable.purchasableTypeId == 1) this.business.amountEmployed++;
        if (purchasable.purchasableTypeId == 2)
          this.business.amountOwnedItems++;
        setState(() {
          // Current adjusted cost
          purchasable.amountOwnedByBusiness +=
              1; // Increase amount owned after taking adjusted cost
        });

        purchaseDebouncer.run(() => PurchasableStore()
            .purchaseItem(this.business?.id.toString(),
                purchasable.id.toString(), purchaseAmount.toString())
            .then((value) => setState(() {
                  // Real stats updates. Update stats based on db
                  purchasable.amountOwnedByBusiness =
                      value.purchasable.amountOwnedByBusiness;
                  purchasable = value.purchasable;
                  this.business.cash = value.business.cash;
                  this.business.cashPerSecond = value.business.cashPerSecond;
                  this.business.amountEmployed = value.business.amountEmployed;
                  this.business.maxEmployeeAmount =
                      value.business.maxEmployeeAmount;
                  this.business.espionageChance =
                      value.business.espionageChance;
                  this.business.espionageDefense =
                      value.business.espionageDefense;
                  this.business.lifeTimeEarnings =
                      value.business.lifeTimeEarnings;
                }))
            .whenComplete(() => purchaseAmount = 0));
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
