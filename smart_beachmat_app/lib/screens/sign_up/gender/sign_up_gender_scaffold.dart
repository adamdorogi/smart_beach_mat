import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/widgets/left_app_bar.dart';
import 'package:smart_beachmat_app/screens/sign_up/gender/sign_up_gender_form.dart';
import 'package:smart_beachmat_app/models/user.dart';

class SignUpGenderScaffold extends StatelessWidget {
  final User _user;

  const SignUpGenderScaffold(this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeftAppBar(
        context,
        title: Text('Sir? Ma\'am?'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(17),
            child: Text(
              'What\'s your gender?',
              style: Theme.of(context).primaryTextTheme.subhead,
            ),
          ),
          SignUpGenderForm(_user),
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
