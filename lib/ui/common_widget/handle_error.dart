import 'package:flutter/material.dart';

void handleError(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message)
      )
  );
}
