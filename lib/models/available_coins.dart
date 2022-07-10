import 'dart:math';

import 'package:coinslib/coinslib.dart';
import 'coin.dart';

class AvailableCoins {
  static final Map<String, Coin> _availableCoinList = {
  'sumcoin': Coin(
    name: 'sumcoin',
    displayName: 'Sumcoin',
    uriCode: 'sumcoin',
    letterCode: 'SUM',
    iconPath: 'assets/icon/sum-icon-white-64.png',
    iconPathTransparent: 'assets/icon/sum-icon-white-64.png',
    networkType: NetworkType(
      messagePrefix: '\Sumcoin Signed Message:\n',
      bech32: 'sum',
      bip32: Bip32Type(public: 0x0488b41c, private: 0x0488abe6),
      pubKeyHash: 0x3F,
      scriptHash: 0x05,
      wif: 0xBF,
      opreturnSize: 100,
    ),
    fractions: 8,
    minimumTxValue: 10000,
    feePerKb: 0.001,
    explorerUrl: 'https://insight.sumcore.org',
    genesisHash:
        '37d4696c5072cd012f3b7c651e5ce56a1383577e4edacc2d289ec9b25eebfd5e',
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
