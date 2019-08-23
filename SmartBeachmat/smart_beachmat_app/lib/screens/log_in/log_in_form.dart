import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

import 'package:smart_beachmat_app/api_exception.dart';
import 'package:smart_beachmat_app/api_service.dart';
import 'package:smart_beachmat_app/main.dart';
import 'package:smart_beachmat_app/models/database_provider.dart';
import 'package:smart_beachmat_app/models/user.dart';
import 'package:smart_beachmat_app/widgets/sign_up_button.dart';

class LogInForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const LogInForm(this.formKey);

  @override
  State<StatefulWidget> createState() {
    return _LogInFormState();
  }
}

class _LogInFormState extends State<LogInForm> {
  String _email;
  String _password;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
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
          obscureText: true,
          decoration: InputDecoration(labelText: 'Password'),
          onSaved: (String value) => _password = value,
        ),
        SignUpButton(
          child: Text('Log In'),
          onPressed: _isButtonEnabled ? _submit : null,
        ),
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

  void _validateForm() {
    bool isFormValid = _validateEmail(_emailController.text) &&
        _validatePassword(_passwordController.text);

    if (_isButtonEnabled != isFormValid) {
      setState(() {
        _isButtonEnabled = isFormValid;
      });
    }
  }

  Future<void> _submit() async {
    widget.formKey.currentState.save();

    try {
      Response tokenResponse =
          await ApiService().createToken(email: _email, password: _password);

      String token = json.decode(tokenResponse.body)['token'];
      FlutterSecureStorage storage = FlutterSecureStorage();
      await storage.write(key: 'token', value: token);

      Response userResponse = await ApiService().readUsers();

      for (var user in json.decode(userResponse.body)) {
        await DatabaseProvider.addUser(User.fromJson(user));
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } on ApiException catch (err) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
