import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/screens/sign_up/dob/sign_up_dob_scaffold.dart';
import 'package:smart_beachmat_app/models/user.dart';
import 'package:smart_beachmat_app/widgets/chip_wrap.dart';
import 'package:smart_beachmat_app/widgets/sign_up_button.dart';

class SignUpGenderForm extends StatefulWidget {
  final User user;

  const SignUpGenderForm(this.user);

  @override
  State<StatefulWidget> createState() {
    return _SignUpGenderFormState();
  }
}

class _SignUpGenderFormState extends State<SignUpGenderForm> {
  List<String> _genders = <String>['👨', '👩'];
  int _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ChipWrap(
          children: List<ChoiceChip>.generate(
            _genders.length,
            (int index) {
              return ChoiceChip(
                backgroundColor: Colors.transparent,
                label: Text(
                  _genders[index] +
                      ['🏻', '🏼', '🏽', '🏾', '🏿'][widget.user.skinType - 2],
                  style: TextStyle(fontSize: 51),
                ),
                selected: _currentIndex == index,
                onSelected: (bool selected) {
                  setState(() => _currentIndex = index);
                },
              );
            },
          ),
        ),
        SignUpButton(
          child: Text('Continue'),
          onPressed: _currentIndex == null ? null : _continue,
        ),
      ],
    );
  }

  void _continue() {
    widget.user.gender = ['m', 'f'][_currentIndex];

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignUpDobScaffold(widget.user)));
  }
}
