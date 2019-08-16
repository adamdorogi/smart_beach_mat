import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:smart_beachmat_app/bottom_navigation_scaffold.dart';
import 'package:smart_beachmat_app/sign_up_scaffold.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final _storage = FlutterSecureStorage();

  Future<String> _read({@required String key}) async =>
      await _storage.read(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _read(key: 'token'),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold();
            case ConnectionState.done:
              if (snapshot.hasData) {
                return BottomNavigationScaffold();
              }
              return SignUpScaffold();
            default:
              return SignUpScaffold();
          }
        },
      ),
    );
  }
}
