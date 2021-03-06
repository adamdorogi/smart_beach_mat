import 'package:flutter/material.dart';

class SignUpButton extends StatelessWidget {
  final Function onPressed;
  final Widget child;

  SignUpButton({this.onPressed, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: RaisedButton(
        color: Theme.of(context).primaryColor,
        highlightColor: Theme.of(context).primaryColor,
        disabledColor: Theme.of(context).primaryColor.withOpacity(0.5),
        child: child,
        onPressed: onPressed,
        elevation: 16.0,
        highlightElevation: 8,
      ),
      padding: EdgeInsets.all(17),
    );
  }
}
