import 'package:flutter/material.dart';

final ThemeData customTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  primaryTextTheme: Typography.blackCupertino.copyWith(
    title: Typography.blackCupertino.title.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.bold,
    ),
  ),
  appBarTheme: AppBarTheme(
    color: Colors.white,
    brightness: Brightness.light,
    elevation: 0.0,
  ),
  buttonTheme: ButtonThemeData(
    shape: StadiumBorder(),
    minWidth: double.infinity,
    height: 50,
    textTheme: ButtonTextTheme.primary,
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.all(17),
  ),
);
