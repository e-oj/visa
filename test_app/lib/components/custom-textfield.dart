import 'package:flutter/material.dart';
import '../app-scale.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField(this.label, {Key key, this.width, this.initialValue})
      : super(key: key);

  final String initialValue;
  final String label;
  final double width;

  @override
  _CustomTextFieldState createState() =>
      _CustomTextFieldState(label, width: width, initialValue: initialValue);
}

class _CustomTextFieldState extends State<CustomTextField> {
  _CustomTextFieldState(this.label, {this.width, this.initialValue});

  final String initialValue;
  final String label;
  final double width;
  Color labelColor;
  FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();

    focusNode.addListener(() => {changeLabelColor(focusNode)});
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void changeLabelColor(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      setState(() => labelColor = Colors.black);
    } else {
      setState(() => labelColor = Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppScale scale = AppScale(context);

    return Flexible(
        child: Container(
            margin: EdgeInsets.fromLTRB(0, scale.ofHeight(0.020), 0, 0),
            child: FractionallySizedBox(
                widthFactor: width != null ? width : 0.8,
                child: TextFormField(
                  initialValue: initialValue,
                  focusNode: focusNode,
                  cursorColor: Colors.black,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      // hintText: label,
                      labelText: label,
                      labelStyle: TextStyle(
                          color: labelColor, fontSize: scale.ofHeight(0.020))),
                ))));
  }
}
