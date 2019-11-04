import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/screens/log_in/log_in_form.dart';
import 'package:smart_beachmat_app/screens/sign_up/email/sign_up_email_scaffold.dart';
import 'package:smart_beachmat_app/widgets/left_app_bar.dart';

class LogInScaffold extends StatelessWidget {
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeftAppBar(
        context,
        title: Text('Log In'),
      ),
      body: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: LogInForm(_formKey),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Don\'t have an account? ',
                style: Theme.of(context).primaryTextTheme.caption,
              ),
              InkWell(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpEmailScaffold(),
                  ),
                ),
                child: Text(
                  'Sign up.',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .caption
                      .copyWith(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
