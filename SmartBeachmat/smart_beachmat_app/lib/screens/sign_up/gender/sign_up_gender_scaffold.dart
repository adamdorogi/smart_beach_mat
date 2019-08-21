import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/widgets/left_app_bar.dart';
import 'package:smart_beachmat_app/screens/sign_up/gender/sign_up_gender_form.dart';
import 'package:smart_beachmat_app/user.dart';

class SignUpGenderScaffold extends StatelessWidget {
  final User _user;

  const SignUpGenderScaffold(this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeftAppBar(
        context,
        title: Text('What\'s your gender?'),
      ),
      body: SignUpGenderForm(_user),
    );
  }
}
