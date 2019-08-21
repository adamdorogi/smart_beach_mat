import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:smart_beachmat_app/api_service.dart';
import 'package:smart_beachmat_app/user.dart';
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
  DateTime _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(_selectedDate.toString()),
        RaisedButton(
          child: Text('Select birthday'),
          onPressed: _showDatePicker,
        ),
        SignUpButton(
          child: Text('Continue'),
          onPressed: _selectedDate == null ? null : _continue,
        )
      ],
    );
  }

  Future<void> _showDatePicker() async {
    DateTime now = DateTime.now();

    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: now,
    );

    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _continue() async {
    widget.user.dob = DateFormat('yyyy-MM-dd').format(_selectedDate);

    await ApiService().createUser(widget.user);
  }
}
