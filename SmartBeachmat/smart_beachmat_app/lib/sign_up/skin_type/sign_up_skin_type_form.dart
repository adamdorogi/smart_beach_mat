import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/sign_up/gender/sign_up_gender_form.dart';
import 'package:smart_beachmat_app/user.dart';

class SignUpSkinTypeForm extends StatefulWidget {
  final User user;

  const SignUpSkinTypeForm(this.user);

  @override
  State<StatefulWidget> createState() {
    return _SignUpSkinTypeFormState();
  }
}

class _SignUpSkinTypeFormState extends State<SignUpSkinTypeForm> {
  List<String> _skinTypes = <String>['I', 'II', 'III', 'IV', 'V', 'VI'];
  int _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Wrap(
          children: List<ChoiceChip>.generate(
            _skinTypes.length,
            (int index) {
              return ChoiceChip(
                label: Text(_skinTypes[index]),
                selected: _currentIndex == index,
                onSelected: (_) {
                  setState(() => _currentIndex = index);
                },
              );
            },
          ),
        ),
        RaisedButton(
          child: Text('Continue'),
          onPressed: _currentIndex == null ? null : _continue,
        )
      ],
    );
  }

  void _continue() {
    widget.user.skinType = _currentIndex + 1;

    print(widget.user.toString());

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SignUpGenderForm(widget.user)));
  }
}
