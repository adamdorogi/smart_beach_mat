import 'package:flutter/material.dart';

import 'package:smart_beachmat_app/screens/sign_up/skin_type/sign_up_skin_type_scaffold.dart';
import 'package:smart_beachmat_app/models/user.dart';
import 'package:smart_beachmat_app/widgets/sign_up_button.dart';

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

  TextEditingController _nameController = new TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(labelText: 'Your name'),
          onSaved: (String value) => _name = value,
        ),
        SignUpButton(
          child: Text('Continue'),
          onPressed: _isButtonEnabled ? _continue : null,
        )
      ],
    );
  }

  void _validateName() {
    if (_isButtonEnabled != _nameController.text.isNotEmpty) {
      setState(() {
        _isButtonEnabled = _nameController.text.isNotEmpty;
      });
    }
  }

  void _continue() {
    widget.formKey.currentState.save();

    User user = User(name: _name);

    print(user.toString());

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SignUpSkinTypeScaffold(user)));
  }
}
