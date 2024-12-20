import 'package:flutter/material.dart';

class Styles {
  ThemeData themeData(BuildContext context) {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 14, 106, 62),
      colorScheme: ThemeData().colorScheme.copyWith(
            secondary: const Color.fromARGB(255, 19, 154, 132),
          ),
      cardColor: const Color.fromARGB(255, 9, 129, 109),
      canvasColor: const Color.fromARGB(192, 3, 59, 102),
    );
  }
}
