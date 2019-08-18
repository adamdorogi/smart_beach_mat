import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:smart_beachmat_app/bottom_navigation_scaffold.dart';
import 'package:smart_beachmat_app/sign_up/email/sign_up_email_scaffold.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final _storage = FlutterSecureStorage();

  Future<String> _read({@required String key}) async => _storage.read(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _read(key: 'token'),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return BottomNavigationScaffold();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold();
          }
          return SignUpEmailScaffold();
        },
      ),
    );
  }
}
