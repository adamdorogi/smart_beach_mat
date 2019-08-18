import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/api_exception.dart';
import 'package:smart_beachmat_app/api_service.dart';
import 'package:smart_beachmat_app/sign_up/name/sign_up_name_scaffold.dart';

class SignUpFormBody extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const SignUpFormBody(this.formKey);

  @override
  State<StatefulWidget> createState() {
    return _SignUpFormBodyState();
  }
}

class _SignUpFormBodyState extends State<SignUpFormBody> {
  final GlobalKey<FormFieldState> _passwordKey = GlobalKey<FormFieldState>();

  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'Email'),
          validator: _validateEmail,
          onSaved: (String value) => email = value),
      TextFormField(
          key: _passwordKey,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
          validator: _validatePassword,
          onSaved: (String value) => password = value),
      TextFormField(
        obscureText: true,
        decoration: InputDecoration(labelText: 'Confirm password'),
        validator: _validateConfirmPassword,
      ),
      RaisedButton(
        child: Text('Sign Up'),
        onPressed: _submit,
      )
    ]);
  }

  String _validateEmail(String email) {
    final Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    if (!RegExp(pattern).hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  String _validateConfirmPassword(String confirmPassword) {
    if (_passwordKey.currentState.value != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (widget.formKey.currentState.validate()) {
      widget.formKey.currentState.save();

      try {
        await ApiService().createAccount(email: email, password: password);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SignUpNameScaffold()));
      } on ApiException catch (err) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(err.message),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}
