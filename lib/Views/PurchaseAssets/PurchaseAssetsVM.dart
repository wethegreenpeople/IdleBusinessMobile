import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Helpers/AppHelper.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';
import 'package:idlebusiness_mobile/Stores/PurchasableStore.dart';
import 'package:idlebusiness_mobile/Views/Login/Login.dart';
import 'package:idlebusiness_mobile/Views/PurchaseAssets/CustomColors.dart';
import 'package:idlebusiness_mobile/Views/Sector/Sector.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseAssetsVM extends ChangeNotifier {
  final Business business;
  final purchaseDebouncer = Debouncer(milliseconds: 750);

  int _purchaseAmount = 0; // Keep track of how many purchases we make in one go
  Timer _cashIncreaseTimer; // Timer to track our cash increase per second

  bool get canViewMarketplace {
    return business.lifeTimeEarnings > 1000000;
  }

  PurchaseAssetsVM(BuildContext context, this.business) {
    if (this.business != null &&
        this.business.sectorId == null &&
        this.business.lifeTimeEarnings >= 10000000) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var okButton = TextButton(
          child: Text(
            "Join Now",
            style: TextStyle(color: CustomColors.colorPrimaryButton),
          ),
          onPressed: () {
            _pushSectorScreen(context);
          },
        );

        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('!!!'),
                  content: Text(
                      "Congrats! Your business is large enough to join a sector. Join now?"),
                  actions: [okButton],
                ));
      });
    }
  }

  void purchaseAsset(Purchasable purchasable) {
    _purchaseAmount++;
    // "fake" stats updates. Update stats immediately for the user's enjoyment
    this.business.cash -= purchasable.calculateAdjustedCost();
    this.business.cashPerSecond += purchasable.cashPerSecondMod;
    this.business.maxItemAmount += purchasable.maxItemsMod;
    this.business.maxEmployeeAmount += purchasable.maxEmployeeMod;
    this.business.espionageChance += purchasable.espionageChanceMod;
    this.business.espionageDefense += purchasable.espionageDefenseMod;
    if (purchasable.purchasableTypeId == 1) this.business.amountEmployed++;
    if (purchasable.purchasableTypeId == 2) this.business.amountOwnedItems++;
    if (purchasable.purchasableTypeId == 4) purchasable.amountAvailable--;
    // Current adjusted cost
    purchasable.amountOwnedByBusiness +=
        1; // Increase amount owned after taking adjusted cost
    notifyListeners();

    purchaseDebouncer.run(() => PurchasableStore()
            .purchaseItem(this.business.id.toString(),
                purchasable.id.toString(), _purchaseAmount.toString())
            .then((value) {
          // Real stats updates. Update stats based on db
          purchasable.amountOwnedByBusiness =
              value.purchasable.amountOwnedByBusiness;
          purchasable = value.purchasable;
          purchasable.amountAvailable = value.purchasable.amountAvailable;
          this.business.cash = value.business.cash;
          this.business.cashPerSecond = value.business.cashPerSecond;
          this.business.amountEmployed = value.business.amountEmployed;
          this.business.maxEmployeeAmount = value.business.maxEmployeeAmount;
          this.business.espionageChance = value.business.espionageChance;
          this.business.espionageDefense = value.business.espionageDefense;
          this.business.lifeTimeEarnings = value.business.lifeTimeEarnings;
        }).whenComplete(() {
          _purchaseAmount = 0;
          notifyListeners();
        }));
  }

  void startCashIncreaseTimer() {
    if (_cashIncreaseTimer == null) {
      _cashIncreaseTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        this.business.cash += this.business.cashPerSecond;
        this.business.lifeTimeEarnings += this.business.cashPerSecond;
        notifyListeners();
      });
    }
  }

  Future<void> _setLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSignedIn', false);
  }

  Future<void> _pushLogin(BuildContext context) async {
    await pushNewScreen(
      context,
      screen: LoginPage(),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  Future<void> _pushSectorScreen(BuildContext context) async {
    await pushNewScreen(
      context,
      screen: SectorPage(this.business),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  void logOut(BuildContext context) async {
    await _setLoginState();
    await _pushLogin(context);
  }
}
