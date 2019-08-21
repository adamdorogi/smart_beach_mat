import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/widgets/left_app_bar.dart';
import 'package:smart_beachmat_app/screens/sign_up/dob/sign_up_dob_form.dart';
import 'package:smart_beachmat_app/models/user.dart';

class SignUpDobScaffold extends StatelessWidget {
  final User _user;

  const SignUpDobScaffold(this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeftAppBar(
        context,
        title: Text('Age? 🎂'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(17),
            child: Text(
              'When were you born?',
              style: Theme.of(context).primaryTextTheme.subhead,
            ),
          ),
          SignUpDobForm(_user),
          Padding(
            padding: EdgeInsets.all(17),
            child: Text(
              'Why? We\'ll need this to calculate your UV thershold!',
              style: Theme.of(context).primaryTextTheme.caption,
            ),
          ),
        ],
      ),
    );
  }
}
