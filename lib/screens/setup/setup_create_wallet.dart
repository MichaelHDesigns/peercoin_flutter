import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peercoin/screens/setup/setup.dart';
import 'package:provider/provider.dart';

import '../../providers/active_wallets.dart';
import '../../providers/app_settings.dart';
import '../../providers/encrypted_box.dart';
import '../../providers/unencrypted_options.dart';
import '../../tools/app_localizations.dart';
import '../../tools/app_routes.dart';
import '../../tools/share_wrapper.dart';
import '../../widgets/buttons.dart';

class SetupCreateWalletScreen extends StatefulWidget {
  @override
  _SetupCreateWalletScreenState createState() =>
      _SetupCreateWalletScreenState();
}

class _SetupCreateWalletScreenState extends State<SetupCreateWalletScreen> {
  bool _sharedYet = false;
  bool _initial = true;
  String _seed = '';
  double _currentSliderValue = 12;
  late ActiveWallets _activeWallets;

  Future<void> shareSeed(seed) async {
    if (kIsWeb) {
      await Clipboard.setData(
        ClipboardData(text: seed),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          AppLocalizations.instance.translate('snack_copied'),
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 3),
      ));
    } else {
      await ShareWrapper.share(seed);
    }
    Timer(
      Duration(seconds: kIsWeb ? 2 : 1),
      () => setState(() {
        _sharedYet = true;
      }),
    );
  }

  @override
  void didChangeDependencies() async {
    if (_initial) {
      _activeWallets = Provider.of<ActiveWallets>(context);
      _seed = await _activeWallets.seedPhrase;

      setState(() {
        _initial = false;
      });
    }

    super.didChangeDependencies();
  }

  void recreatePhrase(double sliderValue) async {
    var _entropy = 128;
    var _intValue = sliderValue.toInt();

    switch (_intValue) {
      case 15:
        _entropy = 160;
        break;
      case 18:
        _entropy = 192;
        break;
      case 21:
        _entropy = 224;
        break;
      case 24:
        _entropy = 256;
        break;
      default:
        _entropy = 128;
    }

    await _activeWallets.createPhrase(null, _entropy);
    _seed = await _activeWallets.seedPhrase;

    setState(() {
      _sharedYet = false;
    });
  }

  Future<void> handleContinue() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('setup_continue_alert_title'),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalizations.instance.translate('setup_continue_alert_content'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('server_settings_alert_cancel'),
              ),
            ),
            TextButton(
              onPressed: () async {
                var prefs = await Provider.of<UnencryptedOptions>(context,
                        listen: false)
                    .prefs;
                await prefs.setBool('importedSeed', false);
                Navigator.pop(context);

                if (kIsWeb) {
                  var settings =
                      Provider.of<AppSettings>(context, listen: false);
                  await settings.init(true);
                  await settings.createInitialSettings(
                      false, AppLocalizations.instance.locale.toString());
                  await Navigator.pushNamed(
                    context,
                    Routes.SetupDataFeeds,
                  );
                } else {
                  await Navigator.pushNamed(
                    context,
                    Routes.SetUpPin,
                  );
                }
              },
              child: Text(
                AppLocalizations.instance.translate('continue'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: SetupScreen.calcContainerHeight(context),
          color: Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              PeerProgress(2),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          PeerButtonSetupBack(),
                          AutoSizeText(
                            AppLocalizations.instance
                                .translate('setup_save_title'),
                            maxFontSize: 28,
                            minFontSize: 25,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            width: MediaQuery.of(context).size.width > 1200
                                ? MediaQuery.of(context).size.width / 2
                                : MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Theme.of(context).shadowColor,
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.vpn_key_rounded,
                                        color: Theme.of(context).primaryColor,
                                        size: 40,
                                      ),
                                      SizedBox(
                                        width: 24,
                                      ),
                                      Container(
                                        width: MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                1200
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.5
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.9,
                                        child: Text(
                                          AppLocalizations.instance
                                              .translate('setup_save_text1'),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            fontSize: 15,
                                          ),
                                          textAlign: TextAlign.left,
                                          maxLines: 5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onDoubleTap: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        AppLocalizations.instance
                                            .translate('snack_copied'),
                                        textAlign: TextAlign.center,
                                      ),
                                      duration: Duration(seconds: 1),
                                    ));
                                    Clipboard.setData(
                                      ClipboardData(text: _seed),
                                    );
                                    setState(() {
                                      _sharedYet = true;
                                    });
                                  },
                                  child: Container(
                                    height: 250,
                                    padding:
                                        EdgeInsets.fromLTRB(16, 32, 16, 24),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Theme.of(context).backgroundColor,
                                      border: Border.all(
                                        width: 2,
                                        color: _sharedYet
                                            ? Theme.of(context).shadowColor
                                            : Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: getColumn(_seed, 0),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: getColumn(_seed, 1),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: getColumn(_seed, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width > 1200
                                ? MediaQuery.of(context).size.width / 2
                                : MediaQuery.of(context).size.width,
                            child: Slider(
                              activeColor: Colors.white,
                              inactiveColor: Theme.of(context).shadowColor,
                              value: _currentSliderValue,
                              min: 12,
                              max: 24,
                              divisions: 4,
                              label: _currentSliderValue.round().toString(),
                              onChanged: (value) {
                                setState(() {
                                  _currentSliderValue = value;
                                });
                                if (value % 3 == 0) {
                                  recreatePhrase(value);
                                }
                              },
                            ),
                          ),
                          Text(
                            AppLocalizations.instance
                                .translate('setup_seed_slider_label'),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_sharedYet)
                PeerButtonSetup(
                  action: () async => await handleContinue(),
                  text: AppLocalizations.instance.translate('continue'),
                )
              else
                PeerButtonSetup(
                  action: () async => await shareSeed(_seed),
                  text: AppLocalizations.instance.translate('export_now'),
                ),
              SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getColumn(String seed, int pos) {
    var list = <Widget>[];
    var se = seed.split(' ');
    var colSize = se.length ~/ 3;

    for (var i = 0; i < colSize; i++) {
      list.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: i * 3 + pos + 1 < 10
            ? Text(
                '  ' + (i * 3 + pos + 1).toString() + '.  ' + se[i * 3 + pos],
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    fontSize: 16),
              )
            : Text(
                (i * 3 + pos + 1).toString() + '.  ' + se[i * 3 + pos],
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    fontSize: 16),
              ),
      ));
    }
    return list;
  }
//TODO Fix iphone6 problems (containers break)
}
