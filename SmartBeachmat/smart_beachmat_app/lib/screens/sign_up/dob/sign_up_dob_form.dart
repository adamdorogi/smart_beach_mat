import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'package:smart_beachmat_app/main.dart';
import 'package:smart_beachmat_app/models/api_exception.dart';
import 'package:smart_beachmat_app/models/api_service.dart';
import 'package:smart_beachmat_app/models/database_provider.dart';
import 'package:smart_beachmat_app/models/user.dart';
import 'package:smart_beachmat_app/widgets/sign_up_button.dart';

class SignUpDobForm extends StatefulWidget {
  final User user;

  const SignUpDobForm(this.user);

  @override
  State<StatefulWidget> createState() {
    return _SignUpDobFormState();
  }
}

class _SignUpDobFormState extends State<SignUpDobForm> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(17),
            child: Text(
              DateFormat('️️✏️ MMMM d, yyyy').format(_selectedDate),
              style: Theme.of(context).primaryTextTheme.headline,
            ),
          ),
          onTap: _showDatePicker,
        ),
        SignUpButton(
          child: Text('Continue'),
          onPressed: _selectedDate.difference(DateTime.now()).inDays == 0
              ? null
              : _continue,
        ),
      ],
    );
  }

  Future<void> _showDatePicker() async {
    DateTime now = DateTime.now();

    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: _selectedDate,
    );

    setState(() {
      _selectedDate = (date == null) ? _selectedDate : date;
    });
  }

  Future<void> _continue() async {
    widget.user.dob = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      await ApiService().createUser(widget.user);

      Response userResponse = await ApiService().readUsers();
      for (var user in json.decode(userResponse.body)) {
        User test = User.fromJson(user);
        await DatabaseProvider.addUser(test);
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
