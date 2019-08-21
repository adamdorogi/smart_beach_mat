import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/widgets/left_app_bar.dart';
import 'package:smart_beachmat_app/screens/sign_up/name/sign_up_name_form.dart';

class SignUpNameScaffold extends StatelessWidget {
  static GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LeftAppBar(
        title: Text('What should we call you?'),
      ),
      body: Form(
        key: _formKey,
        child: SignUpNameForm(_formKey),
      ),
    );
  }
}
