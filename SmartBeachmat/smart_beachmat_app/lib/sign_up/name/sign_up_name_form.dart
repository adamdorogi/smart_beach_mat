import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/sign_up/skin_type/sign_up_skin_type_scaffold.dart';
import 'package:smart_beachmat_app/user.dart';

class SignUpNameForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  SignUpNameForm(this.formKey);

  @override
  State<StatefulWidget> createState() {
    return _SignUpNameFormState();
  }
}

class _SignUpNameFormState extends State<SignUpNameForm> {
  String _name;
  User _user = User();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: 'Your name'),
            validator: _validateName,
            onSaved: (String value) => _name = value),
        RaisedButton(
          child: Text('Continue'),
          onPressed: _continue,
        )
      ],
    );
  }

  String _validateName(String name) {
    if (name.isEmpty) {
      return 'Please enter a name.';
    }
    return null;
  }

  void _continue() {
    if (widget.formKey.currentState.validate()) {
      widget.formKey.currentState.save();

      _user.name = _name;

      print(_user.toString());

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SignUpSkinTypeScaffold(_user)));
    }
  }
}
