library myWidgets;
import 'package:flutter/material.dart';
import '../../my-globals.dart' as globals;

class myListRowWidgetOneLine extends StatelessWidget {
  final bool isHeader;
  final String Titel1;
  final Color Farbe1;
  final Color? Farbe2;
  final double Breite;
  final double ScaleFactor;
  final Alignment alignment;
  const myListRowWidgetOneLine({
    Key? key,required this.isHeader, required this.Titel1, required this.Farbe1, required this.Farbe2, required this.Breite, required this.ScaleFactor, required this.alignment
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.Breite,
      alignment: this.alignment,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(this.Titel1,
            textScaleFactor: this.ScaleFactor,
            style: this.ScaleFactor < 1.0 ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                width: 0.0,
                color: (this.isHeader) ? Colors.grey : globals.BgColorNeutral
            ),
            left: BorderSide(
                width: 0.0,
                color: (this.isHeader) ? Colors.grey : globals.BgColorNeutral
            ),
            right: BorderSide(
                width: 0.0,
                color: (this.isHeader) ? Colors.grey : globals.BgColorNeutral
            ),
            bottom: BorderSide(
                width: 3.0,
                color: this.Farbe1
            )
        ),
        color: this.Farbe2,
      ),
    );
  }
}

class myListRowWidgetTwoLines extends StatelessWidget {
  final bool isHeader;
  final String Titel1;
  final String Titel2;
  final Color Farbe1;
  final Color? Farbe2;
  final double Breite;
  final double ScaleFactor;
  const myListRowWidgetTwoLines({
    Key? key,required this.isHeader, required this.Titel1, required this.Titel2, required this.Farbe1, required this.Farbe2, required this.Breite, required this.ScaleFactor

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: this.Breite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(this.Titel1, textScaleFactor: this.ScaleFactor,style: this.ScaleFactor < 1.0 ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(fontWeight: FontWeight.normal),),
              Text(this.Titel2, textScaleFactor: this.ScaleFactor,style: this.ScaleFactor < 1.0 ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(fontWeight: FontWeight.normal),),
            ],
          ),
          decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
                    width: 0.0,
                    color: (this.isHeader) ? Colors.grey : globals.BgColorNeutral
                ),
                left: BorderSide(
                    width: 0.0,
                    color: (this.isHeader) ? Colors.grey : globals.BgColorNeutral
                ),
                right: BorderSide(
                    width: 0.0,
                    color: (this.isHeader) ? Colors.grey : globals.BgColorNeutral
                ),
                bottom: BorderSide(
                    width: 3.0,
                    color: this.Farbe1
                )
            ),
            color: this.Farbe2,
          ),
        ),
      ],
    );
  }
}
