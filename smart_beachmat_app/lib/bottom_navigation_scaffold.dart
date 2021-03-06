import 'dart:async';
import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/dashboard_widget.dart';
import 'package:smart_beachmat_app/screens/device_connect_scaffold.dart';
import 'package:smart_beachmat_app/widgets/bottom_navigation_widget.dart';
import 'package:smart_beachmat_app/widgets/left_app_bar.dart';
import 'package:smart_beachmat_app/profile_widget.dart';

class BottomNavigationScaffold extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BottomNavigationScaffoldState();
}

class _BottomNavigationScaffoldState extends State<BottomNavigationScaffold> {
  int _currentIndex = 0;

  static final List<BottomNavigationWidget> _pages = <BottomNavigationWidget>[
    BottomNavigationWidget(
      title: Text('Dashboard'),
      child: DashboardWidget(),
      icon: Icon(Icons.dashboard),
    ),
    BottomNavigationWidget(
      title: Text('Profile'),
      child: ProfileWidget(),
      icon: Icon(Icons.account_circle),
    ),
  ];

  final List<BottomNavigationBarItem> _bottomNavigationBarItems =
      _pages.map((item) => item.bottomNavigationBarItem).toList();

  Future<bool> didConnectToDevice() async => false; // TODO: store in user defaults?

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: didConnectToDevice(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return Scaffold(
            appBar: LeftAppBar(
              context,
              title: _pages[_currentIndex].title,
            ),
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _currentIndex,
              items: _bottomNavigationBarItems,
              onTap: _onTap,
            ),
          );
        } else {
          return DeviceConnectScaffold();
        }
      },
    );
  }

  void _onTap(int index) => setState(() => _currentIndex = index);
}
