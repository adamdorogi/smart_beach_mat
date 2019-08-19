import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/screens/sign_up/dob/sign_up_dob_form.dart';
import 'package:smart_beachmat_app/user.dart';

class SignUpDobScaffold extends StatelessWidget {
  final User _user;

  const SignUpDobScaffold(this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('When were you born?'),
      ),
      body: SignUpDobForm(_user),
    );
  }
}
