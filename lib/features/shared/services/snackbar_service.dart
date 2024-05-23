import 'package:flutter/material.dart';
import 'package:push_app_notification/config/router/app_router.dart';

enum SnackbarType { info, success, error, floating }

class SnackbarService {
  static void showSnackbar({
    required String message,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    if (rootNavigatorKey.currentContext == null) return;
    ScaffoldMessenger.of(rootNavigatorKey.currentContext!)
        .hideCurrentSnackBar();
    ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 350,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
          ),
        ),
        backgroundColor: Colors.grey[200],
        duration: duration,
      ),
    );
  }
}
