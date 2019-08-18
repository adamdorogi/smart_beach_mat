import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/sign_up/email/sign_up_email_form.dart';

class SignUpEmailScaffold extends StatelessWidget {
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SignUpEmailForm(_formKey),
      ),
    );
  }
}
