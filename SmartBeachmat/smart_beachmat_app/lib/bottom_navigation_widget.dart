import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final Text title;
  final Widget child;
  final Icon icon;

  BottomNavigationBarItem get bottomNavigationBarItem {
    return BottomNavigationBarItem(
      title: title,
      icon: icon,
    );
  }

  BottomNavigationWidget(
      {@required this.title, this.child, @required this.icon});

  @override
  Widget build(BuildContext context) => child;
}
