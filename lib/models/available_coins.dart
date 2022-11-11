import 'dart:math';

import 'package:coinslib/coinslib.dart';
import 'coin.dart';

class AvailableCoins {
  static final Map<String, Coin> _availableCoinList = {
  'hthcoin': Coin(
    name: 'hthcoin',
    displayName: 'Hthcoin',
    uriCode: 'hthcoin',
    letterCode: 'HTH',
    iconPath: 'assets/icon/sum-icon-white-64.png',
    iconPathTransparent: 'assets/icon/sum-icon-white-64.png',
    networkType: NetworkType(
      messagePrefix: '\HomelessCoin Signed Message:\n',
      bech32: 'hth',
      bip32: Bip32Type(public: 0x0488b21e, private: 0xeeaeeacc),
      pubKeyHash: 0x256,
      scriptHash: 0x64,
      wif: 0xe4,
      opreturnSize: 100,
    ),
    fractions: 8,
    minimumTxValue: 10000,
    feePerKb: 0.001,
    explorerUrl: 'http://154.12.237.243:3001/insight/',
    genesisHash:
        '37540c3c757bb77e42c168d8197447b6aba38c2d1ec0ddf59d2e774c41953093',
    txVersion: 1,
  ),
};

  static Map<String, Coin> get availableCoins {
    return _availableCoinList;
  }

  static Coin getSpecificCoin(String identifier) {
    return _availableCoinList[identifier]!;
  }

  static int getDecimalProduct({required String identifier}) {
    return pow(
      10,
      getSpecificCoin(identifier).fractions,
    ).toInt();
  }
}
