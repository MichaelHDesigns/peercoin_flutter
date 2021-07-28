[![Peercoin Donate](https://badgen.net/badge/peercoin/Donate/green?icon=https://raw.githubusercontent.com/peercoin/media/84710cca6c3c8d2d79676e5260cc8d1cd729a427/Peercoin%202020%20Logo%20Files/01.%20Icon%20Only/Inside%20Circle/Transparent/Green%20Icon/peercoin-icon-green-transparent.svg)](https://chainz.cryptoid.info/ppc/address.dws?PPXMXETHJE3E8k6s8vmpDC18b7y5eKAudS)
<a href="https://weblate.ppc.lol/engage/peercoin-flutter/">
<img src="https://weblate.ppc.lol/widgets/peercoin-flutter/-/translations/svg-badge.svg" alt="Übersetzungsstatus" /></a>
[![Codemagic build status](https://api.codemagic.io/apps/61012a37d885ed7a8c3e8b25/61012a37d885ed7a8c3e8b24/status_badge.svg)](https://codemagic.io/apps/61012a37d885ed7a8c3e8b25/61012a37d885ed7a8c3e8b24/latest_build)
[![Build and Test Flutter App](https://github.com/peercoin/peercoin_flutter/actions/workflows/flutter-drive.yml/badge.svg)](https://github.com/peercoin/peercoin_flutter/actions/workflows/flutter-drive.yml)
# peercoin_flutter
Wallet for Peercoin and Peercoin Testnet using Electrumx as backend.  
**App in constant development**  
Basic testing successfull on iOS 14.4 and Android 10.  
**Use at own risk.**  

![Screenshot_small](https://user-images.githubusercontent.com/11148913/124509449-470f7c80-ddd2-11eb-9daf-56de7eb83594.png)

## Help Translate
<a href="https://weblate.ppc.lol/engage/peercoin-flutter/">
<img src="https://weblate.ppc.lol/widgets/peercoin-flutter/-/translations/multi-auto.svg" alt="Translation status" />
</a>

## Known Limitations
- can't send to Multisig addresses
- adds 1 Satoshi extra fee due to sporadic internal rounding errors 
- will not mint

## Development
This repository currently relies on a fork of bitcoin_flutter, which can be found here: 
[peercoin/bitcoin_flutter](https://github.com/peercoin/bitcoin_flutter "github.com/peercoin/bitcoin_flutter")

The original library is not compatible, due to transaction timestamp incompability. 

**Update icons**  
`flutter pub run flutter_launcher_icons:main`

**Update Hive adapters**  
`flutter packages pub run build_runner build`

**Update splash screen**  
`flutter pub run flutter_native_splash:create`

## Basic e2e testing
`flutter drive --target=test_driver/app.dart --driver=test_driver/key_new.dart`  
`flutter drive --target=test_driver/app.dart --driver=test_driver/key_imported.dart`
