import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/widgets/left_app_bar.dart';
import 'package:smart_beachmat_app/screens/sign_up/skin_type/sign_up_skin_type_form.dart';
import 'package:smart_beachmat_app/models/user.dart';

class SignUpSkinTypeScaffold extends StatelessWidget {
  final User _user;

  const SignUpSkinTypeScaffold(this._user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeftAppBar(
        context,
        title: Text('Hello, ${_user.name}! 👋'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(17),
            child: Text(
              'What\'s your skin type?',
              style: Theme.of(context).primaryTextTheme.subhead,
            ),
          ),
          SignUpSkinTypeForm(_user),
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
