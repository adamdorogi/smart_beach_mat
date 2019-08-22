import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/screens/sign_up/gender/sign_up_gender_scaffold.dart';
import 'package:smart_beachmat_app/models/user.dart';
import 'package:smart_beachmat_app/widgets/chip_wrap.dart';
import 'package:smart_beachmat_app/widgets/sign_up_button.dart';

class SignUpSkinTypeForm extends StatefulWidget {
  final User user;

  const SignUpSkinTypeForm(this.user);

  @override
  State<StatefulWidget> createState() {
    return _SignUpSkinTypeFormState();
  }
}

class _SignUpSkinTypeFormState extends State<SignUpSkinTypeForm> {
  List<String> _skinTypes = <String>['🧑🏻', '🧑🏼', '🧑🏽', '🧑🏾', '🧑🏿'];
  int _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ChipWrap(
          children: List<ChoiceChip>.generate(
            _skinTypes.length,
            (int index) {
              return ChoiceChip(
                backgroundColor: Colors.transparent,
                label: Text(
                  _skinTypes[index],
                  style: TextStyle(fontSize: 51),
                ),
                selected: _currentIndex == index,
                onSelected: (_) {
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
    widget.user.skinType = _currentIndex + 2;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SignUpGenderScaffold(widget.user)),
    );
  }
}
