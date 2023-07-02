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
      alignment: alignment,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(Titel1,
            textScaleFactor: ScaleFactor,
            style: ScaleFactor < 1.0 ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                width: 0.0,
                color: (isHeader) ? Colors.grey : globals.BgColorNeutral
            ),
            left: BorderSide(
                width: 0.0,
                color: (isHeader) ? Colors.grey : globals.BgColorNeutral
            ),
            right: BorderSide(
                width: 0.0,
                color: (isHeader) ? Colors.grey : globals.BgColorNeutral
            ),
            bottom: BorderSide(
                width: 3.0,
                color: Farbe1
            )
        ),
        color: Farbe2,
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
  final double Padding;
  const myListRowWidgetTwoLines({
    Key? key,
    required this.isHeader,
    required this.Titel1,
    required this.Titel2,
    required this.Farbe1,
    required this.Farbe2,
    required this.Breite,
    required this.ScaleFactor,
    required this.Padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Breite,
      padding: EdgeInsets.all(Padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(Titel1, textScaleFactor: ScaleFactor,style: ScaleFactor < 1.0 ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(fontWeight: FontWeight.normal),),
          Text(Titel2, textScaleFactor: ScaleFactor,style: ScaleFactor < 1.0 ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(fontWeight: FontWeight.normal),),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                width: 0.0,
                color: (isHeader) ? Colors.grey : globals.BgColorNeutral
            ),
            left: BorderSide(
                width: 0.0,
                color: (isHeader) ? Colors.grey : globals.BgColorNeutral
            ),
            right: BorderSide(
                width: 0.0,
                color: (isHeader) ? Colors.grey : globals.BgColorNeutral
            ),
            bottom: BorderSide(
                width: 3.0,
                color: Farbe1
            )
        ),
        color: Farbe2,
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
    if ( Zeitpunkt.isEmpty ) {
      return "kein Datum";
    } else {
      return "${Zeitpunkt.substring(8, 10)}.${Zeitpunkt.substring(5, 7)}.${Zeitpunkt.substring(0, 4)}";
    }
  }
  String dieUhrzeit(String Zeitpunkt) {
    if ( Zeitpunkt.isEmpty ) {
      return "keine Uhrzeit";
    } else {
      return Zeitpunkt.substring(11, 16);
    }
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
    int Pulsdruck = Systole - Diastole;
    print(Gewicht.toString());

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
                  Titel1: dasDatum(Zeitpunkt),
                  Titel2: dieUhrzeit(Zeitpunkt),
                  Farbe1: globals.BgColorNeutral,
                  Farbe2: globals.BgColorNeutral,
                  Breite: _BreiteZeitpunkt,
                  ScaleFactor: _scaleFactor,
                  Padding: 8.0,
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            child: myListRowWidgetOneLine(
                              isHeader: false,
                              Titel1: Systole.toString(),
                              Farbe1: globals.Farbe1Systole(Systole),
                              Farbe2: globals.Farbe2Systole(Systole),
                              Breite: _BreiteZeitpunkt / 2.0,
                              ScaleFactor: _scaleFactor,
                              alignment: Alignment.center,
                            ),
                          ),
                          Flexible(
                            child: myListRowWidgetOneLine(
                              isHeader: false,
                              Titel1: Diastole.toString(),
                              Farbe1: globals.Farbe1Diastole(Diastole),
                              Farbe2: globals.Farbe2Diastole(Diastole),
                              Breite: _BreiteZeitpunkt / 2.0,
                              ScaleFactor: _scaleFactor,
                              alignment: Alignment.center,
                            ),
                          ),
                          Flexible(
                            child: myListRowWidgetOneLine(
                              isHeader: false,
                              Titel1: Puls != null ? this.Puls.toString() : "---",
                              Farbe1: Puls != null ? globals.Farbe1Puls(Puls!) : globals.BgColorNeutral,
                              Farbe2: Puls != null ? globals.Farbe2Puls(Puls!) : globals.BgColorNeutral,
                              Breite: _BreiteZeitpunkt / 2.0,
                              ScaleFactor: _scaleFactor,
                              alignment: Alignment.center,
                            ),
                          ),
                          Flexible(
                            child: myListRowWidgetOneLine(
                              isHeader: false,
                              Titel1: Gewicht != null ? Gewicht.toString() : "---",
                              Farbe1: Gewicht != null ? globals.Farbe1Gewicht(Gewicht.toString()!) : globals.BgColorNeutral,
                              Farbe2: Gewicht != null ? globals.Farbe2Gewicht(Gewicht.toString()!) : globals.BgColorNeutral,
                              Breite: _BreiteZeitpunkt / 2.0,
                              ScaleFactor: _scaleFactor,
                              alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1.5,
                            child: Container(
                              color: Pulsdruck < 40
                                ? Colors.yellow[100]
                                : Pulsdruck <= 65.0
                                  ? Colors.green[200]
                                  : Pulsdruck <= 75.0
                                    ? Colors.red[100]
                                    : Pulsdruck <= 90
                                      ? Colors.red[300]
                                      : Colors.red,
                              child: Text('$Pulsdruck', style: const TextStyle(fontSize: 10.0, ), textAlign: TextAlign.center,),
                            ),
                          ),
                        ),
                        const Flexible(
                          flex: 1,
                          child: Text(' '),
                        ),
                        Flexible(
                          flex: 1,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerRight,
                            widthFactor: 0.75,
                            child: Container(
                              color: Gewicht != null ? globals.BMI_Farbe2(Gewicht!) : globals.BgColorNeutral,
                              child: Gewicht != null ? Text(globals.berechneBMI(Gewicht!).toStringAsFixed(1), style: const TextStyle(fontSize: 10.0, ), textAlign: TextAlign.center,) : Text(' ')
                            ),
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 5,),
                    Expanded(
                      child: myListRowWidgetOneLine(
                        isHeader: false,
                        Titel1: Bemerkung.isNotEmpty && Bemerkung != null
                            ? Bemerkung.length > _Bemlen ? Bemerkung.substring(0,_Bemlen) + "...»" : Bemerkung
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
