import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UiUtils {
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin:EdgeInsets.all(16) ,
      ),
    );
  }
}
