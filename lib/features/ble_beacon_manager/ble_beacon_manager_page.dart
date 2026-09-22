import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_beacon.dart';
import 'ble_beacon_store.dart';

class BleBeaconManagerPage extends StatefulWidget {
  const BleBeaconManagerPage({super.key});

  @override
  State<BleBeaconManagerPage> createState() =>
      _BleBeaconManagerPageState();
}

class _BleBeaconManagerPageState
    extends State<BleBeaconManagerPage> {
  final BleBeaconStore store =
      BleBeaconStore.instance;

  bool loading = true;
  bool scanning = false;

  // Filter is OFF by default.
  bool filterEnabled = false;

  StreamSubscription<List<ScanResult>>?
      _scanSubscription;

  // Contains ALL currently detected BLE devices.
  final Map<String, ScanResult> _scannedDevices = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await store.load();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  // ------------------------------------------------------------
  // BLE SCANNING
  // ------------------------------------------------------------

  Future<void> _scan() async {
    if (scanning) return;

    if (FlutterBluePlus.isScanningNow) {
      debugPrint('BLE scan is already running');
      return;
    }

    setState(() {
      scanning = true;
      _scannedDevices.clear();
    });

    await _scanSubscription?.cancel();

    _scanSubscription =
        FlutterBluePlus.onScanResults.listen(
      (results) {
        for (final result in results) {
          final mac =
              result.device.remoteId.str.toUpperCase();

          final name =
              result.device.platformName.isNotEmpty
                  ? result.device.platformName
                  : result.advertisementData.advName;

          debugPrint(
            'BLE DEVICE → '
            'Name: $name | '
            'MAC: $mac | '
            'RSSI: ${result.rssi}',
          );

          // IMPORTANT:
          // Store EVERY detected BLE device.
          //
          // Do NOT check store.isRegistered() here.
          // Filtering is handled only when displaying.
          _scannedDevices[mac] = result;
        }

        if (mounted) {
          setState(() {});
        }
      },
      onError: (error) {
        debugPrint('BLE SCAN ERROR: $error');
      },
    );

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 8),
        androidScanMode:
            AndroidScanMode.lowLatency,
      );

      await FlutterBluePlus.isScanning
          .where((value) => value == false)
          .first;
    } catch (e) {
      debugPrint('BLE SCAN FAILED: $e');
    } finally {
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      if (mounted) {
        setState(() {
          scanning = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // DEVICE NAME
  // ------------------------------------------------------------

  String _deviceName(ScanResult result) {
    if (result.device.platformName.isNotEmpty) {
      return result.device.platformName;
    }

    if (result.advertisementData.advName.isNotEmpty) {
      return result.advertisementData.advName;
    }

    return 'Unknown BLE Device';
  }

  // ------------------------------------------------------------
  // FILTERED DEVICES
  // ------------------------------------------------------------

  List<ScanResult> get _visibleDevices {
    final devices = _scannedDevices.values.toList();

    // Filter OFF → show ALL devices.
    if (!filterEnabled) {
      return devices;
    }

    // Filter ON → show ONLY registered/configured MACs.
    return devices.where((result) {
      final mac =
          result.device.remoteId.str.toUpperCase();

      return store.isRegistered(mac);
    }).toList();
  }

  // ------------------------------------------------------------
  // REGISTER FROM BLE SCAN
  // ------------------------------------------------------------

  Future<void> _addFromScan(
    ScanResult result,
  ) async {
    final mac =
        result.device.remoteId.str.toUpperCase();

    final advertisedName =
        _deviceName(result);

    final nameController =
        TextEditingController(
      text: advertisedName ==
              'Unknown BLE Device'
          ? ''
          : advertisedName,
    );

    final resultValue =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Register BLE Beacon',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mac,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(
                  labelText: 'Beacon Name',
                  hintText:
                      'Example: Entrance Beacon',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  nameController.text.trim(),
                );
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );

    nameController.dispose();

    if (resultValue == null) {
      return;
    }

    final success =
        await store.addBeacon(
      macAddress: mac,
      name: resultValue,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'This MAC address is already registered.',
          ),
        ),
      );
    }

    setState(() {});
  }

  // ------------------------------------------------------------
  // ADD MAC MANUALLY
  // ------------------------------------------------------------

  Future<void> _addManually() async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return const _AddBleBeaconDialog();
      },
    );

    if (!mounted) return;

    if (result == false) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid or duplicate MAC address.',
          ),
        ),
      );
    }

    setState(() {});
  }

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  Future<void> _delete(
    BleBeacon beacon,
  ) async {
    await store.removeBeacon(
      beacon.macAddress,
    );

    if (!mounted) return;

    setState(() {});
  }

  // ------------------------------------------------------------
  // EDIT BEACON
  // ------------------------------------------------------------

  Future<void> _editBeacon(
    BleBeacon beacon,
  ) async {
    final nameController =
        TextEditingController(
      text: beacon.name,
    );

    final newName =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit BLE Beacon',
          ),
          content: TextField(
            controller: nameController,
            decoration:
                const InputDecoration(
              labelText: 'Beacon Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  nameController.text.trim(),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();

    if (newName == null) {
      return;
    }

    await store.updateBeacon(
      beacon.macAddress,
      beacon.macAddress,
      newName,
    );

    if (!mounted) return;

    setState(() {});
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final registered = store.beacons;
    final visibleDevices = _visibleDevices;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BLE Beacon Manager',
        ),
        actions: [
          IconButton(
            tooltip: scanning
                ? 'Scanning...'
                : 'Scan BLE devices',
            icon: Icon(
              scanning
                  ? Icons.stop
                  : Icons.bluetooth_searching,
            ),
            onPressed:
                scanning ? null : _scan,
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addManually,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add MAC',
        ),
      ),

      body: Column(
        children: [

          // ------------------------------------------------------
          // SCAN BUTTON
          // ------------------------------------------------------

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    scanning ? null : _scan,
                icon: const Icon(
                  Icons.bluetooth_searching,
                ),
                label: Text(
                  scanning
                      ? 'Scanning...'
                      : 'Scan BLE Devices',
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // FILTER CONFIGURATION
          // ------------------------------------------------------

          Card(
            margin:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt_outlined,
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter by configured MAC',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Show only registered BLE beacons',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Switch(
                    value: filterEnabled,
                    onChanged: (value) {
                      setState(() {
                        filterEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ------------------------------------------------------
          // SCAN RESULT COUNT
          // ------------------------------------------------------

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Row(
              children: [
                Text(
                  filterEnabled
                      ? 'Configured devices'
                      : 'All detected devices',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  '${visibleDevices.length} device${visibleDevices.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // DEVICE LIST
          // ------------------------------------------------------

          Expanded(
            child: visibleDevices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          filterEnabled
                              ? Icons.filter_alt_off
                              : Icons.bluetooth_disabled,
                          size: 60,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          filterEnabled
                              ? 'No configured BLE devices detected.'
                              : 'No BLE devices detected.',
                        ),

                        const SizedBox(height: 6),

                        Text(
                          scanning
                              ? 'Scanning for nearby devices...'
                              : 'Tap Scan BLE Devices to scan.',
                          style:
                              const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.all(12),
                    itemCount:
                        visibleDevices.length,
                    itemBuilder:
                        (context, index) {
                      final result =
                          visibleDevices[index];

                      final mac = result
                          .device
                          .remoteId
                          .str
                          .toUpperCase();

                      final name =
                          _deviceName(result);

                      final registeredBeacon =
                          registered.where(
                        (beacon) =>
                            beacon.macAddress
                                .toUpperCase() ==
                            mac,
                      ).firstOrNull;

                      final isRegistered =
                          registeredBeacon !=
                              null;

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          // ------------------------------------------------
                          // ICON
                          // ------------------------------------------------

                          leading: CircleAvatar(
                            child: Icon(
                              isRegistered
                                  ? Icons.bluetooth
                                  : Icons
                                      .bluetooth_outlined,
                            ),
                          ),

                          // ------------------------------------------------
                          // DEVICE NAME
                          // ------------------------------------------------

                          title: Text(
                            isRegistered
                                ? registeredBeacon!
                                    .name
                                : name,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          // ------------------------------------------------
                          // MAC + RSSI + STATUS
                          // ------------------------------------------------

                          subtitle: Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              top: 5,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [

                                // MAC ADDRESS
                                Text(
                                  mac,
                                  style:
                                      const TextStyle(
                                    fontFamily:
                                        'monospace',
                                  ),
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                // RSSI
                                Text(
                                  'RSSI: ${result.rssi} dBm',
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                // STATUS
                                Text(
                                  isRegistered
                                      ? 'Configured beacon'
                                      : 'Detected device',
                                  style:
                                      TextStyle(
                                    color:
                                        isRegistered
                                            ? Colors
                                                .green
                                            : Colors
                                                .blue,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ------------------------------------------------
                          // ACTIONS
                          // ------------------------------------------------

                          trailing:
                              isRegistered
                                  ? PopupMenuButton<
                                      String>(
                                      onSelected:
                                          (value) {
                                        if (value ==
                                            'edit') {
                                          _editBeacon(
                                            registeredBeacon!,
                                          );
                                        }

                                        if (value ==
                                            'delete') {
                                          _delete(
                                            registeredBeacon!,
                                          );
                                        }
                                      },
                                      itemBuilder:
                                          (context) =>
                                              const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .edit_outlined,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'Edit',
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value:
                                              'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .delete_outline,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'Delete',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : IconButton(
                                      tooltip:
                                          'Register this device',
                                      icon: const Icon(
                                        Icons
                                            .add_circle_outline,
                                      ),
                                      onPressed: () =>
                                          _addFromScan(
                                        result,
                                      ),
                                    ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ADD BLE BEACON DIALOG
// ============================================================================

class _AddBleBeaconDialog
    extends StatefulWidget {
  const _AddBleBeaconDialog();

  @override
  State<_AddBleBeaconDialog> createState() =>
      _AddBleBeaconDialogState();
}

class _AddBleBeaconDialogState
    extends State<_AddBleBeaconDialog> {
  final TextEditingController
      macController =
      TextEditingController();

  final TextEditingController
      nameController =
      TextEditingController();

  bool saving = false;

  @override
  void dispose() {
    macController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final mac =
        macController.text.trim();
    final name =
        nameController.text.trim();

    if (mac.isEmpty) {
      return;
    }

    setState(() {
      saving = true;
    });

    final store =
        BleBeaconStore.instance;

    final success =
        await store.addBeacon(
      macAddress: mac,
      name: name.isEmpty
          ? 'BLE Beacon'
          : name,
    );

    if (!mounted) return;

    Navigator.pop(
      context,
      success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          const Text('Add BLE Beacon'),

      content:
          SingleChildScrollView(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [

            TextField(
              controller:
                  macController,
              enabled: !saving,
              textCapitalization:
                  TextCapitalization
                      .characters,
              decoration:
                  const InputDecoration(
                labelText:
                    'MAC Address',
                hintText:
                    'AA:BB:CC:DD:EE:FF',
                prefixIcon:
                    Icon(
                  Icons.bluetooth,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  nameController,
              enabled: !saving,
              decoration:
                  const InputDecoration(
                labelText:
                    'Beacon Name',
                hintText:
                    'Example: Entrance Beacon',
                prefixIcon:
                    Icon(
                  Icons.label_outline,
                ),
              ),
            ),
          ],
        ),
      ),

      actions: [

        TextButton(
          onPressed: saving
              ? null
              : () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
          child:
              const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed:
              saving ? null : _save,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}