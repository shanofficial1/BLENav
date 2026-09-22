import 'package:flutter/material.dart';

import '../shared/widgets/dashboard_card.dart';
import '../shared/widgets/section_title.dart';
import '../features/indoor_map/indoor_map_page.dart';

import '../features/beacon_setup/beacon_setup_page.dart';

import '../features/path_setup/path_setup_page.dart';

import '../features/ble_beacon_manager/ble_beacon_manager_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IndoorNav"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: [

            const SizedBox(height: 20),

            const Center(
              child: Text(
                "Indoor Navigation System",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Center(
              child: Text(
                "Version 1.1",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SectionTitle(title: "User"),

            DashboardCard(
              icon: Icons.map,
              title: "Indoor Map",
              subtitle: "Live indoor navigation",
              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const IndoorMapPage(),
    ),
  );
},
            ),

            DashboardCard(
              icon: Icons.search,
              title: "Search Destination",
              subtitle: "Find classrooms and labs",
              onTap: () {},
            ),




            const SectionTitle(title: "Setup"),

DashboardCard(
  icon: Icons.bluetooth_searching,
  title: "BLE Beacon Manager",
  subtitle: "Register and manage BLE MAC addresses",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const BleBeaconManagerPage(),
      ),
    );
  },
),

            DashboardCard(
              icon: Icons.bluetooth_searching,
              title: "Beacon Setup",
              subtitle: "Configure BLE beacons",
              onTap: () {
                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const BeaconSetupPage(),
  ),
);

              },
            ),

            DashboardCard(
              icon: Icons.architecture,
              title: "Room Setup",
              subtitle: "Configure rooms and corridor",
              onTap: () {},
            ),
            DashboardCard(
              icon: Icons.architecture,
              title: "Path Setup",
              subtitle: "Configure paths and routes",
              onTap: () {
                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const PathSetupPage(),
  ),
);
              },
            ),

            const SectionTitle(title: "System"),

            DashboardCard(
              icon: Icons.settings,
              title: "Settings",
              subtitle: "Application settings",
              onTap: () {},
            ),

            const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }
}