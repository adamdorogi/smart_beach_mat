import 'package:flutter/material.dart';

class SignUpFormBody extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  SignUpFormBody(this.formKey);

  @override
  State<StatefulWidget> createState() {
    return _SignUpFormBodyState();
  }
}

class _SignUpFormBodyState extends State<SignUpFormBody> {
  final _passwordKey = GlobalKey<FormFieldState>();

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
    Pattern pattern =
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

  void _submit() {
    if (widget.formKey.currentState.validate()) {
      widget.formKey.currentState.save();
      // send account creation request
      print('EMAIL: $email, PASSWORD: $password');
    }
  }
}
