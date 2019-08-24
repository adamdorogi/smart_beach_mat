import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/bottom_navigation_scaffold.dart';
import 'package:smart_beachmat_app/models/database_provider.dart';
import 'package:smart_beachmat_app/models/secure_storage_provider.dart';
import 'package:smart_beachmat_app/models/theme.dart';
import 'package:smart_beachmat_app/models/user.dart';
import 'package:smart_beachmat_app/screens/sign_up/email/sign_up_email_scaffold.dart';
import 'package:smart_beachmat_app/screens/sign_up/name/sign_up_name_scaffold.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: customTheme,
      home: FutureBuilder(
        future: SecureStorageProvider.getToken(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
              future: DatabaseProvider.getUsers(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  return BottomNavigationScaffold();
                } else {
                  return SignUpNameScaffold();
                }
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold();
          }
          return SignUpEmailScaffold();
        },
      ),
    );
  }
}
