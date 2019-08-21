import 'package:flutter/material.dart';

class ChipWrap extends StatelessWidget {
  final List<ChoiceChip> children;

  ChipWrap({this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      alignment: WrapAlignment.spaceEvenly,
      children: children,
    );
  }
}
