import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/bottom_navigation_scaffold.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomNavigationScaffold(),
    );
  }
}
