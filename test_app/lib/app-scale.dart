import 'package:flutter/material.dart';

class AppScale {
  const AppScale(this._context);

  final BuildContext _context;

  double ofWidth(double pct) {
    return MediaQuery.of(_context).size.width * pct;
  }

  double ofHeight(double pct) {
    return MediaQuery.of(this._context).size.height * pct;
  }
}
