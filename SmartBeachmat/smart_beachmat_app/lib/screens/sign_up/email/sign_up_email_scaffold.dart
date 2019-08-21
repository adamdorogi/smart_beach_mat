import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/widgets/left_app_bar.dart';
import 'package:smart_beachmat_app/screens/sign_up/email/sign_up_email_form.dart';

class SignUpEmailScaffold extends StatelessWidget {
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeftAppBar(
        context,
        title: Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SignUpEmailForm(_formKey),
      ),
    );
  }
}
