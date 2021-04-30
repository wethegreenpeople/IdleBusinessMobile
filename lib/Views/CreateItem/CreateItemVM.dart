import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';

class CreateItemVM extends ChangeNotifier {
  final Business business;
  final TextEditingController itemNameController = TextEditingController();

  int _currentProductionAmountValue = 10;
  int get currentProductionAmountValue {
    return _currentProductionAmountValue;
  }

  set currentProductionAmountValue(int value) {
    if (value != _currentProductionAmountValue) {
      _currentProductionAmountValue = value;
      notifyListeners();
    }
  }

  double get costToProduce {
    return (business.lifeTimeEarnings * .10) *
        (100.0 / currentProductionAmountValue);
  }

  double get costPerItem {
    return (costToProduce / currentProductionAmountValue) * .1;
  }

  double get cpsGainPerItem {
    return (business.cashPerSecond * .25) / (currentProductionAmountValue * 2) <
            100
        ? 100
        : (business.cashPerSecond * .25) / (currentProductionAmountValue * 2);
  }

  double get profit {
    return costToProduce + (costToProduce * .1);
  }

  CreateItemVM(BuildContext context, this.business) {
    updateBusinessGains(this.business.id.toString());
  }
}
