library myWidgets;
import 'package:flutter/material.dart';
import '../../my-globals.dart' as globals;
import 'screenhelper.dart';

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
      // width: this.Breite,
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
    Key? key,
    required this.isHeader,
    required this.Titel1,
    required this.Titel2,
    required this.Farbe1,
    required this.Farbe2,
    required this.Breite,
    required this.ScaleFactor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class datenZeile extends StatelessWidget {
  final String Zeitpunkt;
  final int Systole;
  final int Diastole;
  final int? Puls;
  final double? Gewicht;
  final String Bemerkung;
  const datenZeile({Key? key,
    required this.Zeitpunkt,
    required this.Systole,
    required this.Diastole,
    required this.Puls,
    required this.Gewicht,
    required this.Bemerkung
  }) : super(key: key);

  String dasDatum(String Zeitpunkt) {
    if ( Zeitpunkt.length == 0 ) return "kein Datum";
    else return Zeitpunkt.substring(8, 10) + "." + Zeitpunkt.substring(5, 7) + "." + Zeitpunkt.substring(0, 4);
  }
  String dieUhrzeit(String Zeitpunkt) {
    if ( Zeitpunkt.length == 0 ) return "keine Uhrzeit";
    else return Zeitpunkt.substring(11, 16);
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = Screen.isLandscape(context);
    // bool isLargePhone = Screen.diagonal(context) > 720;
    // bool isNarrow = Screen.widthInches(context) < 3.5;
    bool isTablet = Screen.diagonalInches(context) >= 8.5; // war 7s
    double _scaleFactor = isTablet ? globals.scaleFactorTablet : globals.scaleFactorPhone;
    int _Bemlen = isTablet ? globals.BemlenTablet : globals.BemlenPhone;
    double _BreiteZeitpunkt = MediaQuery.of(context).size.width / 3.0;

    return Column(
      children: [
        Flexible(flex: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: myListRowWidgetTwoLines(
                  isHeader: false,
                  Titel1: dasDatum(this.Zeitpunkt),
                  Titel2: dieUhrzeit(this.Zeitpunkt),
                  Farbe1: globals.BgColorNeutral,
                  Farbe2: globals.BgColorNeutral,
                  Breite: _BreiteZeitpunkt,
                  ScaleFactor: _scaleFactor,),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            child: myListRowWidgetOneLine(
                              isHeader: false,
                              Titel1: this.Systole.toString(),
                              Farbe1: globals.Farbe1Systole(this.Systole),
                              Farbe2: globals.Farbe2Systole(this.Systole),
                              Breite: _BreiteZeitpunkt / 2.0,
                              ScaleFactor: _scaleFactor,
                              alignment: Alignment.center,
                            ),
                          ),
                          Flexible(
                            child: myListRowWidgetOneLine(
                              isHeader: false,
                              Titel1: this.Diastole.toString(),
                              Farbe1: globals.Farbe1Diastole(this.Diastole),
                              Farbe2: globals.Farbe2Diastole(this.Diastole),
                              Breite: _BreiteZeitpunkt / 2.0,
                              ScaleFactor: _scaleFactor,
                              alignment: Alignment.center,
                            ),
                          ),
                          Flexible(
                            child: myListRowWidgetOneLine(
                              isHeader: false,
                              Titel1: this.Puls.toString().isNotEmpty ? this.Puls.toString() : "---",
                              Farbe1: this.Puls.toString().isNotEmpty ? globals.Farbe1Puls(this.Puls!) : globals.BgColorNeutral,
                              Farbe2: this.Puls.toString().isNotEmpty ? globals.Farbe2Puls(this.Puls!) : globals.BgColorNeutral,
                              Breite: _BreiteZeitpunkt / 2.0,
                              ScaleFactor: _scaleFactor,
                              alignment: Alignment.center,
                            ),
                          ),
                          Flexible(
                            child: myListRowWidgetOneLine(
                              isHeader: false,
                              Titel1: this.Gewicht.toString().isNotEmpty && this.Gewicht != null ? this.Gewicht.toString() : "---",
                              Farbe1: this.Gewicht.toString().isNotEmpty ? globals.Farbe1Gewicht(this.Gewicht.toString()) : globals.BgColorNeutral,
                              Farbe2: this.Gewicht.toString().isNotEmpty ? globals.Farbe2Gewicht(this.Gewicht.toString()) : globals.BgColorNeutral,
                              Breite: _BreiteZeitpunkt / 2.0,
                              ScaleFactor: _scaleFactor,
                              alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Expanded(
                      child: myListRowWidgetOneLine(
                        isHeader: false,
                        Titel1: this.Bemerkung.isNotEmpty && this.Bemerkung != null
                            ? this.Bemerkung.length > _Bemlen ? this.Bemerkung.substring(0,_Bemlen) + "...»" : this.Bemerkung
                            : "",
                        Farbe1: globals.BgColorNeutral,
                        Farbe2: globals.BgColorNeutral,
                        Breite: _BreiteZeitpunkt * 2.0,
                        ScaleFactor: _scaleFactor,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Flexible(flex: 1,
          child: Container(color: Colors.black12,),
        ),
      ],
    );
  }
}
