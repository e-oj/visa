import 'package:flutter/material.dart';

class Debug {
  Debug({required this.prefix});

  String prefix;

  info(String s) {
    print(prefix);
    print('--VISA-DEBUG: ${this.prefix} $s');
  }
}
