import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/sign_up/skin_type/sign_up_skin_type_form.dart';
import 'package:smart_beachmat_app/user.dart';

class SignUpSkinTypeScaffold extends StatelessWidget {
  final User _user;

  const SignUpSkinTypeScaffold(this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What\'s your skin type?'),
      ),
      body: SignUpSkinTypeForm(_user),
    );
  }
}
