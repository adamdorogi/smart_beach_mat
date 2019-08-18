import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/sign_up/name/sign_up_name_form.dart';

class SignUpNameScaffold extends StatelessWidget {
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What should we call you?'),
      ),
      body: Form(
        key: _formKey,
        child: SignUpNameForm(_formKey),
      ),
    );
  }
}
