import 'package:flutter/material.dart';

import 'components/custom-button.dart';
import 'app-scale.dart';

class Utils {
  static getButton(
      {@required String text,
      @required VoidCallback onPressed,
      double width: 0.75,
      double height: 0.055,
      Color color,
      Color textColor,
      Widget icon}) {
    return CustomButton(
        text: text,
        onPressed: onPressed,
        width: width,
        height: height,
        color: color,
        textColor: textColor,
        icon: icon);
  }

  static getAppBar(BuildContext context, {bool canGoBack = true}) {
    AppScale scale = AppScale(context);

    return AppBar(
      title: Text('Visa'),
      toolbarHeight: scale.ofHeight(0.076),
      leading: canGoBack
          ? new IconButton(
              icon: new Icon(Icons.arrow_back, size: scale.ofHeight(0.033)),
              onPressed: () => Navigator.pop(context))
          : null,
      // elevation: 0,
      centerTitle: true,
    );
  }
}
