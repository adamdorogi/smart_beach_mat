import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/sign_up/gender/sign_up_gender_form.dart';
import 'package:smart_beachmat_app/user.dart';

class SignUpGenderScaffold extends StatelessWidget {
  final User _user;

  const SignUpGenderScaffold(this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What\'s your gender?'),
      ),
      body: SignUpGenderForm(_user),
    );
  }
}
