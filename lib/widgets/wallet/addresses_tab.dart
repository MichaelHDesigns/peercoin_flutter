import 'package:auto_size_text/auto_size_text.dart';
import 'package:coinslib/coinslib.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:peercoin/providers/electrum_connection.dart';
import 'package:peercoin/widgets/wallet/wallet_home_qr.dart';
import 'package:provider/provider.dart';

import '../../models/available_coins.dart';
import '../../models/coin.dart';
import '../../models/wallet_address.dart';
import '../../providers/active_wallets.dart';
import '../../providers/app_settings.dart';
import '../../screens/wallet/wallet_home.dart';
import '../../tools/app_localizations.dart';
import '../../tools/auth.dart';
import '../../tools/logger_wrapper.dart';
import '../double_tab_to_clipboard.dart';

class AddressTab extends StatefulWidget {
  final String _walletName;
  final String title;
  final List<WalletAddress>? _walletAddresses;
  final Function changeIndex;
  const AddressTab(
      this._walletName, this.title, this._walletAddresses, this.changeIndex,
      {Key? key})
      : super(key: key);
  @override
  _AddressTabState createState() => _AddressTabState();
}

class _AddressTabState extends State<AddressTab> {
  bool _initial = true;
  List<WalletAddress> _filteredSend = [];
  List<WalletAddress> _filteredReceive = [];
  late Coin _availableCoin;
  final _formKey = GlobalKey<FormState>();
  final _searchKey = GlobalKey<FormFieldState>();
  final searchController = TextEditingController();
  bool _search = false;
  bool _showChangeAddresses = true;
  bool _optionsExpanded = false;
  bool _showLabel = true;
  bool _showUsed = true;
  bool _showEmpty = true;
  bool _showUnwatched = true;
  final Map _addressBalanceMap = {};
  final Map _isWatchedMap = {};
  late ActiveWallets _activeWallets;
  late ElectrumConnection _connection;
  late Iterable _listenedAddresses;
  late final int _decimalProduct;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      applyFilter();
      _availableCoin = AvailableCoins.getSpecificCoin(widget._walletName);
      _activeWallets = Provider.of<ActiveWallets>(context);
      _connection = Provider.of<ElectrumConnection>(context);
      _listenedAddresses = _connection.listenedAddresses.keys;
      _decimalProduct = AvailableCoins.getDecimalProduct(
        identifier: widget._walletName,
      );
      await fillAddressBalanceMap();
      setState(() {
        _initial = false;
      });
      applyFilter();
    }
    super.didChangeDependencies();
  }

  Future<void> fillAddressBalanceMap() async {
    final utxos = await _activeWallets.getWalletUtxos(widget._walletName);
    for (var tx in utxos) {
      if (tx.value > 0) {
        if (_addressBalanceMap[tx.address] != null) {
          _addressBalanceMap[tx.address] += tx.value;
        } else {
          _addressBalanceMap[tx.address] = tx.value;
        }
      }
    }
  }

  void applyFilter([String? searchedKey]) {
    if (_initial) return;

    var _filteredListReceive = <WalletAddress>[];
    var _filteredListSend = <WalletAddress>[];

    for (var e in widget._walletAddresses!) {
      if (e.isOurs == true || e.isOurs == null) {
        _filteredListReceive.add(e);
        //fake watch change address and addresses with balance
        if (_addressBalanceMap[e.address] != null ||
            e.address == _activeWallets.getUnusedAddress ||
            e.isWatched == true) {
          _isWatchedMap[e.address] = true;
        } else {
          _isWatchedMap[e.address] = false;
        }
      } else {
        _filteredListSend.add(e);
      }
    }

    //apply filters to receive list
    var _toRemove = [];
    for (var address in _filteredListReceive) {
      if (_showChangeAddresses == false) {
        if (address.isChangeAddr == true) {
          _toRemove.add(address);
        }
      }
      if (_showUsed == false) {
        if (address.used == true) {
          _toRemove.add(address);
        }
      }
      if (_showUnwatched == false) {
        if (_isWatchedMap[address.address] == false) {
          _toRemove.add(address);
        }
      }
      if (_showEmpty == false) {
        if (_addressBalanceMap[address.address] == null) {
          _toRemove.add(address);
        }
      }
    }

    for (var address in _toRemove) {
      _filteredListReceive.remove(address);
    }

    //filter search keys
    if (searchedKey != null) {
      _filteredListReceive = _filteredListReceive.where((element) {
        return element.address.contains(searchedKey) ||
            element.addressBookName != null &&
                element.addressBookName!.contains(searchedKey);
      }).toList();
      _filteredListSend = _filteredListSend.where((element) {
        return element.address.contains(searchedKey) ||
            element.addressBookName != null &&
                element.addressBookName!.contains(searchedKey);
      }).toList();
    }

    setState(() {
      _filteredReceive = _filteredListReceive;
      _filteredSend = _filteredListSend;
    });
  }

  Future<void> _addressEditDialog(
      BuildContext context, WalletAddress address) async {
    var _textFieldController = TextEditingController();
    _textFieldController.text = address.addressBookName ?? '';
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance
                    .translate('addressbook_edit_dialog_title') +
                ' ${address.address}',
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: _textFieldController,
            maxLength: 32,
            decoration: InputDecoration(
                hintText: AppLocalizations.instance
                    .translate('addressbook_edit_dialog_input')),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.instance
                  .translate('server_settings_alert_cancel')),
            ),
            TextButton(
              onPressed: () {
                context.read<ActiveWallets>().updateLabel(widget._walletName,
                    address.address, _textFieldController.text);
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddressExportDialog(
      BuildContext context, WalletAddress address) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance
                .translate('addressbook_export_dialog_title'),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.instance
                    .translate('addressbook_export_dialog_description'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).errorColor,
                ),
              ),
            ],
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
                String _wif;
                if (address.wif!.isEmpty || address.wif == null) {
                  _wif = await context.read<ActiveWallets>().getWif(
                        _availableCoin.name,
                        address.address,
                      );
                } else {
                  _wif = address.wif!;
                }
                Navigator.of(context).pop();
                WalletHomeQr.showQrDialog(context, _wif);
              },
              child: Text(
                AppLocalizations.instance
                    .translate('addressbook_export_dialog_button'),
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> _toggleWatched(WalletAddress addr) async {
    String snackText;
    //addresses with balance or currentChangeAddress can not be unwatched
    if (_addressBalanceMap[addr.address] != null ||
        addr.address == _activeWallets.getUnusedAddress) {
      snackText = 'addressbook_dialog_addr_unwatch_unable';
    } else {
      snackText = _isWatchedMap[addr.address] == true
          ? 'addressbook_dialog_addr_unwatched'
          : 'addressbook_dialog_addr_watched';

      await _activeWallets.updateAddressWatched(
        widget._walletName,
        addr.address,
        !addr.isWatched,
      );

      applyFilter();
      if (_connection.connectionState == ElectrumConnectionState.connected) {
        if (!_listenedAddresses.contains(addr.address) &&
            addr.isWatched == true) {
          //subscribe
          LoggerWrapper.logInfo('AddressTab', '_toggleWatched',
              'watched and subscribed ${addr.address}');
          _connection.subscribeToScriptHashes(
            await _activeWallets.getWalletScriptHashes(
                widget._walletName, addr.address),
          );
        }
      }
    }
    //fire snack
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate(
            snackText,
            {'address': addr.address},
          ),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _addressAddDialog(BuildContext context) async {
    var _labelController = TextEditingController();
    var _addressController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.instance.translate('addressbook_add_new'),
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.instance.translate('send_address'),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.instance
                          .translate('send_enter_address');
                    }
                    var sanitized = value.trim();
                    if (Address.validateAddress(
                            sanitized, _availableCoin.networkType) ==
                        false) {
                      return AppLocalizations.instance
                          .translate('send_invalid_address');
                    }
                    //check if already exists
                    if (widget._walletAddresses!
                        .any((element) => element.address == value)) {
                      return 'Address already exists';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _labelController,
                  maxLength: 32,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.instance.translate('send_label'),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.instance
                  .translate('server_settings_alert_cancel')),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  context.read<ActiveWallets>().updateLabel(
                        widget._walletName,
                        _addressController.text,
                        _labelController.text == ''
                            ? ''
                            : _labelController.text,
                      );
                  applyFilter();
                  Navigator.pop(context);
                }
              },
              child: Text(
                AppLocalizations.instance.translate('jail_dialog_button'),
              ),
            ),
          ],
        );
      },
    );
  }

  String _renderLabel(WalletAddress addr) {
    if (_showLabel) {
      return addr.addressBookName ?? '-';
    }
    var number = _addressBalanceMap[addr.address] ?? 0;
    return '${(number / _decimalProduct)} ${_availableCoin.letterCode}';
  }

  @override
  Widget build(BuildContext context) {
    var listReceive = <Widget>[];
    var listSend = <Widget>[];
    for (var addr in _filteredSend) {
      listSend.add(
        Align(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 1200
                ? MediaQuery.of(context).size.width / 3
                : MediaQuery.of(context).size.width,
            child: DoubleTabToClipboard(
              clipBoardData: addr.address,
              child: Card(
                elevation: 0,
                child: ClipRect(
                  child: Slidable(
                    key: Key(addr.address),
                    actionPane: const SlidableScrollActionPane(),
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: AppLocalizations.instance
                            .translate('addressbook_swipe_edit'),
                        color: Theme.of(context).primaryColor,
                        icon: Icons.edit,
                        onTap: () => _addressEditDialog(context, addr),
                      ),
                      IconSlideAction(
                        caption: AppLocalizations.instance
                            .translate('addressbook_swipe_share'),
                        color: Theme.of(context).backgroundColor,
                        iconWidget: Icon(
                          Icons.share,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onTap: () =>
                            WalletHomeQr.showQrDialog(context, addr.address),
                      ),
                      IconSlideAction(
                        caption: AppLocalizations.instance
                            .translate('addressbook_swipe_send'),
                        color: Theme.of(context).colorScheme.secondary,
                        iconWidget: Icon(
                          Icons.send,
                          color: Theme.of(context).backgroundColor,
                        ),
                        onTap: () => widget.changeIndex(
                          Tabs.send,
                          addr.address,
                          addr.addressBookName,
                        ),
                      ),
                      IconSlideAction(
                        caption: AppLocalizations.instance
                            .translate('addressbook_swipe_delete'),
                        color: Theme.of(context).errorColor,
                        iconWidget:
                            const Icon(Icons.delete, color: Colors.white),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(AppLocalizations.instance.translate(
                                  'addressbook_dialog_remove_title')),
                              content: Text(addr.address),
                              actions: <Widget>[
                                TextButton.icon(
                                    label: Text(AppLocalizations.instance
                                        .translate(
                                            'server_settings_alert_cancel')),
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                                TextButton.icon(
                                  label: Text(AppLocalizations.instance
                                      .translate('jail_dialog_button')),
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    context.read<ActiveWallets>().removeAddress(
                                        widget._walletName, addr);
                                    applyFilter();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.instance.translate(
                                              'addressbook_dialog_remove_snack'),
                                          textAlign: TextAlign.center,
                                        ),
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                    actionExtentRatio: 0.25,
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.swipe_left),
                        ],
                      ),
                      subtitle: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Center(
                          child: Text(addr.address),
                        ),
                      ),
                      title: Center(
                        child: Text(
                          addr.addressBookName ?? '-',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    for (var addr in _filteredReceive) {
      listReceive.add(
        Align(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 1200
                ? MediaQuery.of(context).size.width / 3
                : MediaQuery.of(context).size.width,
            child: DoubleTabToClipboard(
              clipBoardData: addr.address,
              child: Card(
                elevation: 0,
                child: ClipRect(
                  child: Slidable(
                    key: Key(addr.address),
                    actionPane: const SlidableScrollActionPane(),
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: AppLocalizations.instance
                            .translate('addressbook_swipe_edit'),
                        color: Theme.of(context).primaryColor,
                        icon: Icons.edit,
                        onTap: () => _addressEditDialog(context, addr),
                      ),
                      IconSlideAction(
                        caption: AppLocalizations.instance
                            .translate('addressbook_swipe_share'),
                        color: Theme.of(context).backgroundColor,
                        iconWidget: Icon(
                          Icons.share,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onTap: () => WalletHomeQr.showQrDialog(
                          context,
                          addr.address,
                        ),
                      ),
                      IconSlideAction(
                        caption: AppLocalizations.instance.translate(
                          _isWatchedMap[addr.address] == true
                              ? 'addressbook_swipe_unwatch'
                              : 'addressbook_swipe_watch',
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        iconWidget: Icon(
                          _isWatchedMap[addr.address] == true
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Theme.of(context).backgroundColor,
                        ),
                        onTap: () => _toggleWatched(addr),
                      ),
                      IconSlideAction(
                        caption: AppLocalizations.instance
                            .translate('addressbook_swipe_export'),
                        color: Theme.of(context).errorColor,
                        iconWidget: Icon(
                          Icons.vpn_key,
                          color: Theme.of(context).backgroundColor,
                        ),
                        onTap: () => Auth.requireAuth(
                          context: context,
                          biometricsAllowed:
                              context.read<AppSettings>().biometricsAllowed,
                          callback: () =>
                              _showAddressExportDialog(context, addr),
                        ),
                      ),
                    ],
                    actionExtentRatio: 0.25,
                    child: ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.swipe_left),
                        ],
                      ),
                      subtitle: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Center(
                          child: Text(addr.address),
                        ),
                      ),
                      title: Center(
                        child: Text(
                          _renderLabel(addr),
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    var sliverToBoxAdapter = SliverToBoxAdapter(
      child: Column(
        children: [
          ExpansionTile(
            collapsedIconColor: Theme.of(context).colorScheme.onPrimary,
            onExpansionChanged: (_) => setState(
              () {
                _optionsExpanded = _;
              },
            ),
            trailing: Icon(
              _optionsExpanded ? Icons.close : Icons.filter_alt,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            title: Text(
              AppLocalizations.instance
                  .translate('addressbook_bottom_bar_your_addresses'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ChoiceChip(
                        backgroundColor: Theme.of(context).backgroundColor,
                        selectedColor: Theme.of(context).shadowColor,
                        visualDensity:
                            const VisualDensity(horizontal: 0.0, vertical: -4),
                        label: AutoSizeText(
                          AppLocalizations.instance
                              .translate('addressbook_hide_change'),
                          minFontSize: 10,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        selected: _showChangeAddresses,
                        onSelected: (_) {
                          setState(() {
                            _showChangeAddresses = _;
                          });
                          applyFilter();
                        },
                      ),
                      if (kIsWeb)
                        const SizedBox(
                          height: 10,
                        ),
                      ChoiceChip(
                        backgroundColor: Theme.of(context).backgroundColor,
                        selectedColor: Theme.of(context).shadowColor,
                        visualDensity:
                            const VisualDensity(horizontal: 0.0, vertical: -4),
                        label: AutoSizeText(
                          AppLocalizations.instance
                              .translate('addressbook_hide_unwatched'),
                          minFontSize: 10,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        selected: _showUnwatched,
                        onSelected: (_) {
                          setState(() {
                            _showUnwatched = _;
                          });
                          applyFilter();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(kIsWeb ? 8.0 : 0),
                        child: ChoiceChip(
                          backgroundColor: Theme.of(context).backgroundColor,
                          selectedColor: Theme.of(context).shadowColor,
                          visualDensity: const VisualDensity(
                              horizontal: 0.0, vertical: -4),
                          // ignore: avoid_unnecessary_containers
                          label: Container(
                            child: AutoSizeText(
                              _showLabel
                                  ? AppLocalizations.instance
                                      .translate('addressbook_show_balance')
                                  : AppLocalizations.instance
                                      .translate('addressbook_show_label'),
                              textAlign: TextAlign.center,
                              minFontSize: 10,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          selected: _showLabel,
                          onSelected: (_) {
                            setState(
                              () {
                                _showLabel = _;
                              },
                            );
                            applyFilter();
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                          backgroundColor: Theme.of(context).backgroundColor,
                          selectedColor: Theme.of(context).shadowColor,
                          visualDensity: const VisualDensity(
                              horizontal: 0.0, vertical: -4),
                          label: AutoSizeText(
                            AppLocalizations.instance
                                .translate('addressbook_hide_used'),
                            textAlign: TextAlign.center,
                            minFontSize: 10,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          selected: _showUsed,
                          onSelected: (_) {
                            setState(() {
                              _showUsed = _;
                            });
                            applyFilter();
                          }),
                      Padding(
                        padding: const EdgeInsets.all(kIsWeb ? 8.0 : 0),
                        child: ChoiceChip(
                          backgroundColor: Theme.of(context).backgroundColor,
                          selectedColor: Theme.of(context).shadowColor,
                          visualDensity: const VisualDensity(
                              horizontal: 0.0, vertical: -4),
                          label: AutoSizeText(
                            AppLocalizations.instance
                                .translate('addressbook_hide_empty'),
                            textAlign: TextAlign.center,
                            minFontSize: 10,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          selected: _showEmpty,
                          onSelected: (_) {
                            setState(() {
                              _showEmpty = _;
                            });
                            applyFilter();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20)
            ],
          )
        ],
      ),
    );
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true,
                backgroundColor: _search
                    ? Theme.of(context).backgroundColor
                    : Theme.of(context).primaryColor,
                title: Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: _search
                      ? Form(
                          key: _formKey,
                          child: Container(
                            padding: const EdgeInsets.only(left: 16),
                            child: TextFormField(
                              autofocus: true,
                              key: _searchKey,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: AppLocalizations.instance
                                    .translate('addressbook_search'),
                                suffixIcon: IconButton(
                                  icon: const Center(child: Icon(Icons.clear)),
                                  iconSize: 24,
                                  onPressed: () {
                                    _search = false;
                                    applyFilter();
                                  },
                                ),
                              ),
                              onChanged: applyFilter,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).backgroundColor,
                                onPrimary: Theme.of(context).backgroundColor,
                                fixedSize: Size(
                                  MediaQuery.of(context).size.width > 1200
                                      ? MediaQuery.of(context).size.width / 5
                                      : MediaQuery.of(context).size.width / 3,
                                  40,
                                ),
                                shape: RoundedRectangleBorder(
                                  //to set border radius to button
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                      width: 2,
                                      color: Theme.of(context).primaryColor),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (widget._walletAddresses!.isNotEmpty) {
                                  setState(() {
                                    _search = true;
                                  });
                                }
                              },
                              child: Text(
                                AppLocalizations.instance.translate('search'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.4,
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).backgroundColor,
                                onPrimary: Theme.of(context).backgroundColor,
                                fixedSize: Size(
                                  MediaQuery.of(context).size.width > 1200
                                      ? MediaQuery.of(context).size.width / 5
                                      : MediaQuery.of(context).size.width / 3,
                                  40,
                                ),
                                shape: RoundedRectangleBorder(
                                  //to set border radius to button
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    width: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                _addressAddDialog(context);
                              },
                              child: Text(
                                AppLocalizations.instance
                                    .translate('addressbook_new_button'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.4,
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              kIsWeb
                  ? SliverAppBar(
                      centerTitle: false,
                      automaticallyImplyLeading: false,
                      title: Text(
                        AppLocalizations.instance.translate(
                            'addressbook_bottom_bar_sending_addresses'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : SliverAppBar(
                      automaticallyImplyLeading: false,
                      title: Text(
                        AppLocalizations.instance.translate(
                          'addressbook_bottom_bar_sending_addresses',
                        ),
                      ),
                    ),
              SliverList(
                delegate: SliverChildListDelegate(listSend),
              ),
              sliverToBoxAdapter,
              const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),
              SliverList(
                delegate: SliverChildListDelegate(listReceive),
              ),
            ],
          ),
        ),
      ],
    );
  }
  //TODO does not re-render when new address is generated
}
