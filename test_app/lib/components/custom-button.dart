import 'package:flutter/material.dart';
import '../app-scale.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {Key key,
      @required this.text,
      @required this.onPressed,
      this.width,
      this.height,
      this.color,
      this.textColor,
      this.icon})
      : super(key: key);

  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  Widget build(BuildContext context) {
    double width = this.width;
    double height = this.height;
    AppScale scale = AppScale(context);
    Text text =
        Text(this.text, style: TextStyle(fontSize: scale.ofHeight(0.019)));

    if (this.width != null && this.width <= 1) {
      width = scale.ofWidth(this.width);
    }

    if (this.height != null && this.height <= 1) {
      height = scale.ofHeight(this.height);
    }

    return Container(
        width: width,
        height: height,
        margin: EdgeInsets.all(scale.ofHeight(0.011)),
        child: RaisedButton(
          // borderSide: BorderSide(color: Colors.white),
          color: color,
          textColor: textColor,
          child: icon == null
              ? text
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Padding(
                        child: icon,
                        padding:
                            EdgeInsets.fromLTRB(0, 0, scale.ofWidth(0.025), 0),
                      ),
                      text
                    ]),
          onPressed: onPressed,
        ));
  }
}
