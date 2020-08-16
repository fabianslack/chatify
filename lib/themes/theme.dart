import 'package:flutter/material.dart';

ThemeData theme = new ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    buttonColor: const Color(0xff2196f3),
    primaryColor: Color(0xFF303030), // app bar
    accentColor: const Color(0xFF64ffda),
    canvasColor: const Color(0xFF303030),
    backgroundColor: Colors.grey[800],
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 35
    ),

    fontFamily: 'San Fransicso');

ThemeData lightTheme = new ThemeData.light();
