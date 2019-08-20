import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/screens/sign_up/dob/sign_up_dob_scaffold.dart';
import 'package:smart_beachmat_app/user.dart';

class SignUpGenderForm extends StatefulWidget {
  final User user;

  const SignUpGenderForm(this.user);

  @override
  State<StatefulWidget> createState() {
    return _SignUpGenderFormState();
  }
}

class _SignUpGenderFormState extends State<SignUpGenderForm> {
  List<String> _genders = <String>['m', 'f'];
  int _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Wrap(
          children: List<ChoiceChip>.generate(
            _genders.length,
            (int index) {
              return ChoiceChip(
                label: Text(_genders[index]),
                selected: _currentIndex == index,
                onSelected: (bool selected) {
                  setState(() => _currentIndex = index);
                },
              );
            },
          ),
        ),
        RaisedButton(
          child: Text('Continue'),
          onPressed: _currentIndex == null ? null : _continue,
        ),
      ],
    );
  }

  void _continue() {
    widget.user.gender = _genders[_currentIndex];

    print(widget.user.toString());

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpDobScaffold(widget.user)));
  }
}
