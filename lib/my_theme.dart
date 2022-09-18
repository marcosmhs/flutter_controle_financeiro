import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData get theme {
    late var accent = const Color.fromARGB(181, 111, 58, 211);
    late var accentSecond = const Color.fromARGB(181, 164, 157, 173);
    return ThemeData(
      primarySwatch: Colors.deepPurple,
      primaryColor: accent,
      scaffoldBackgroundColor: Colors.grey[100],
      backgroundColor: Colors.white,
      dividerColor: accent,
      disabledColor: accentSecond,
      iconTheme: IconThemeData(color: accent),
      textTheme: TextTheme(headline3: TextStyle(color: accent)),
      //bottomSheetTheme: BottomSheetThemeData(
      //  backgroundColor: accent,
      //  modalBackgroundColor: accent,
      //),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(accent))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(accent),
        side: MaterialStateProperty.all(BorderSide(color: accent)),
      )),
      textButtonTheme: TextButtonThemeData(style: ButtonStyle(foregroundColor: MaterialStateProperty.all(accent))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        labelStyle: TextStyle(color: accent),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(
            color: accent,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(
            color: accent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          borderSide: BorderSide(color: accent),
        ),
      ),
    );
  }
}
