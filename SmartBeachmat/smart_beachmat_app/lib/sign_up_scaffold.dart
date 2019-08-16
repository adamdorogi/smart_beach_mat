import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/sign_up_form_body.dart';

class SignUpScaffold extends StatelessWidget {
  // Create a global key that uniquely identifies the Form widget and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SignUpFormBody(_formKey),
      ),
    );
  }
}
