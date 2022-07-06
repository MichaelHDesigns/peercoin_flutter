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
  'peercoin': Coin(
    name: 'peercoin',
    displayName: 'Peercoin',
    uriCode: 'peercoin',
    letterCode: 'PPC',
    iconPath: 'assets/icon/ppc-icon-48.png',
    iconPathTransparent: 'assets/icon/ppc-icon-white-48.png',
    networkType: NetworkType(
      messagePrefix: 'Peercoin Signed Message:\n',
      bech32: 'pc',
      bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
      pubKeyHash: 0x37,
      scriptHash: 0x75,
      wif: 0xb7,
      opreturnSize: 256,
    ),
    fractions: 6,
    minimumTxValue: 10000,
    feePerKb: 0.01,
    explorerUrl: 'https://blockbook.peercoin.net',
    genesisHash:
        '0000000032fe677166d54963b62a4677d8957e87c508eaa4fd7eb1c880cd27e3',
    txVersion: 3,
  ),
  'bitcoin': Coin(
    name: 'bitcoin',
    displayName: 'Bitcoin',
    uriCode: 'bitcoin',
    letterCode: 'BTC',
    iconPath: 'assets/icon/btc-icon-white-64.png',
    iconPathTransparent: 'assets/icon/btc-icon-white-64.png',
    networkType: NetworkType(
      messagePrefix: '\Bitcoin Signed Message:\n',
      bech32: 'bc',
      bip32: Bip32Type(public: 0x0488B21E, private: 0x0488ADE4),
      pubKeyHash: 0x00,
      scriptHash: 0x05,
      wif: 0x80,
      opreturnSize: 80,
    ),
    fractions: 8,
    minimumTxValue: 10000,
    feePerKb: 0.001,
    explorerUrl: 'https://blockstream.info/',
    genesisHash:
        '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f',
    txVersion: 1,
  ),
  'sumcoincash': Coin(
    name: 'sumcoincash',
    displayName: 'Sumcoin Cash',
    uriCode: 'sumcoincash',
    letterCode: 'SUMC',
    iconPath: 'assets/icon/sum-icon-white-64.png',
    iconPathTransparent: 'assets/icon/sum-icon-white-64.png',
    networkType: NetworkType(
      messagePrefix: '\Sumcoin Cash Signed Message:\n',
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
  'litecoin': Coin(
    name: 'litecoin',
    displayName: 'Litecoin',
    uriCode: 'litecoin',
    letterCode: 'LTC',
    iconPath: 'assets/icon/ltc-icon-white-64.png',
    iconPathTransparent: 'assets/icon/ltc-icon-white-64.png',
    networkType: NetworkType(
      messagePrefix: '\Litecoin Signed Message:\n',
      bech32: 'ltc',
      bip32: Bip32Type(public: 0x0488B21E, private: 0x0488ADE4),
      pubKeyHash: 0x30,
      scriptHash: 0x05,
      wif: 0xB0,
      opreturnSize: 100,
    ),
    fractions: 8,
    minimumTxValue: 10000,
    feePerKb: 0.001,
    explorerUrl: 'https://live.blockcypher.com/ltc/',
    genesisHash:
        '12a765e31ffd4059bada1e25190f6e98c99d9714d334efa41a195a7e7e04bfe2',
    txVersion: 1,
  ),
  'peercoinTestnet': Coin(
    name: 'peercoinTestnet',
    displayName: 'Peercoin Testnet',
    uriCode: 'peercoin',
    letterCode: 'tPPC',
    iconPath: 'assets/icon/ppc-icon-48.png',
    iconPathTransparent: 'assets/icon/ppc-icon-white-48.png',
    networkType: NetworkType(
      messagePrefix: 'Peercoin Signed Message:\n',
      bech32: 'tpc',
      bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
      pubKeyHash: 0x6f,
      scriptHash: 0xc4,
      wif: 0xef,
      opreturnSize: 256,
    ),
    fractions: 6,
    minimumTxValue: 10000,
    feePerKb: 0.01,
    explorerUrl: 'https://tblockbook.peercoin.net',
    genesisHash:
        '00000001f757bb737f6596503e17cd17b0658ce630cc727c0cca81aec47c9f06',
    txVersion: 3,
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
