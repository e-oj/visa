import 'package:flutter/material.dart';
import '../app-scale.dart';
import 'package:hexcolor/hexcolor.dart';

class ImageDisplay extends StatefulWidget {
  ImageDisplay({Key key, this.height, this.margin, this.imageUrl})
      : super(key: key);

  final String imageUrl;
  final double height;
  final EdgeInsets margin;

  @override
  _ImageDisplayState createState() {
    return _ImageDisplayState(height, margin, imageUrl: imageUrl);
  }
}

class _ImageDisplayState extends State<ImageDisplay> {
  _ImageDisplayState(this.height, this.margin, {this.imageUrl});

  String imageUrl;
  double height;
  EdgeInsets margin;
  String imgPath;

  @override
  Widget build(BuildContext context) {
    final AppScale scale = AppScale(context);

    if (margin == null) {
      margin = EdgeInsets.fromLTRB(0, 0, 0, 0);
    }

    return Container(
        width: scale.ofHeight(height),
        height: scale.ofHeight(height),
        margin: margin,
        decoration: BoxDecoration(
          image: imageUrl != null
              ? DecorationImage(image: NetworkImage(imageUrl))
              : null,
          borderRadius: BorderRadius.all(Radius.circular(500)),
          color: HexColor('#f2f2f2'),
        ),
        child: imageUrl == null
            ? Icon(
                Icons.camera_alt,
                size: 45,
                color: Colors.grey,
              )
            : null);
  }
}
