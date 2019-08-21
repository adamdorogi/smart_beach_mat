import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

import 'package:smart_beachmat_app/api_exception.dart';
import 'package:smart_beachmat_app/api_service.dart';
import 'package:smart_beachmat_app/screens/sign_up/name/sign_up_name_scaffold.dart';
import 'package:smart_beachmat_app/widgets/sign_up_button.dart';

class SignUpEmailForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const SignUpEmailForm(this.formKey);

  @override
  State<StatefulWidget> createState() {
    return _SignUpEmailFormState();
  }
}

class _SignUpEmailFormState extends State<SignUpEmailForm> {
  static GlobalKey<FormFieldState> _passwordKey = GlobalKey<FormFieldState>();

  String _email;
  String _password;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _confirmPasswordController =
      new TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'Email'),
          onSaved: (String value) => _email = value,
        ),
        TextFormField(
          controller: _passwordController,
          key: _passwordKey,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
          onSaved: (String value) => _password = value,
        ),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Confirm password'),
        ),
        SignUpButton(
          child: Text('Sign Up'),
          onPressed: _isButtonEnabled ? _submit : null,
        )
      ],
    );
  }

  bool _validateEmail(String email) {
    final Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    return RegExp(pattern).hasMatch(email);
  }

  bool _validatePassword(String password) {
    return password.length >= 8;
  }

  bool _validateConfirmPassword(String confirmPassword) {
    return _passwordKey.currentState.value == confirmPassword;
  }

  void _validateForm() {
    bool isFormValid = _validateEmail(_emailController.text) &&
        _validatePassword(_passwordController.text) &&
        _validateConfirmPassword(_confirmPasswordController.text);

    if (_isButtonEnabled != isFormValid) {
      setState(() {
        _isButtonEnabled = isFormValid;
      });
    }
  }

  Future<void> _submit() async {
    widget.formKey.currentState.save();

    try {
      await ApiService().createAccount(email: _email, password: _password);

      Response response =
          await ApiService().createToken(email: _email, password: _password);

      String token = json.decode(response.body)['token'];
      FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.write(key: 'token', value: token);

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
