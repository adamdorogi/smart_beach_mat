import 'package:flutter/material.dart';

class LeftAppBar extends AppBar {
  final BuildContext context;

  LeftAppBar(this.context, {Text title}) : super(title: title);

  @override
  bool get centerTitle => false;

  @override
  IconThemeData get iconTheme =>
      IconThemeData(color: Theme.of(context).accentColor);
}
