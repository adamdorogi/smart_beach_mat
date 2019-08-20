import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/user.dart';

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
        RaisedButton(
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

  void _continue() {
    widget.user.dob = _selectedDate;
    print(widget.user.toString());
  }
}