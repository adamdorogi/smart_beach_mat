import 'package:flutter/material.dart';

class LeftAppBar extends AppBar {
  LeftAppBar({Text title}) : super(title: title);

  @override
  bool get centerTitle => false;
}