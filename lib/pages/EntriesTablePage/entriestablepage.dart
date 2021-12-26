import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../../my-globals.dart' as globals;

const EntryWidthSysDia = 45.0;

class EntriesTablePage extends StatefulWidget {
  const EntriesTablePage({Key? key}) : super(key: key);

  @override
  _EntriesTablePageState createState() => _EntriesTablePageState();
}

class _EntriesTablePageState extends State<EntriesTablePage> {

  bool _isLoading = true;
  int _Limit = -1;
  int _LimitFromSettings = 25;
  List<Map<String, dynamic>>_alleEintraege = [];

  void _editItem(int ndx, int id) async {
    print("editiere (index: $ndx - ID: $id)");
  }

  void _ladeDaten() async {
    try {
      _LimitFromSettings = await dbHelper.getTabEntryCount();
      _alleEintraege = await dbHelper.getDataItems(_Limit);
      print(_alleEintraege);
      //_alleEintraege.forEach((element) {print(element.toString());});
    } on Error catch( _, e ) {
      print("keine Dateien gefunden");
    }
    if ( mounted ) setState(() {
      _isLoading = false;
    });
  }

  void _neuerEintrag() async {
    try {
      DateTime Zpkt = DateTime.now();
      int Jahr = Zpkt.year;
      int Monat = Zpkt.month;
      int Tag = Zpkt.day;
      int Stunde = Zpkt.hour;
      int Minute = Zpkt.minute;
      int Sekunde = Zpkt.second;
      String Jetzt = Jahr.toString() + "-" + Monat.toString().padLeft(2,'0') + "-" +
          Tag.toString().padLeft(2,'0') + " " + Stunde.toString().padLeft(2,'0') + ":" + Minute.toString().padLeft(2,'0') +
          ":" + Sekunde.toString().padLeft(2,'0');
      int newID = await dbHelper.createDataItem(
          Jetzt, 123, 83, 59, 78.9, "automatisch erstellt");
      Navigator.pop(context, 'OK');
      setState(() {
        _ladeDaten();
      });
    } on Error catch( _, e ) {
      print("Fehler beim Erzeugen eines neuen Eintrags - " + e.toString());
    }
  }

  Color Farbe1Systole(int Wert) {
    if ( Wert<120 ) {                             // optimal
      return globals.SysDia_optimal;
    } else if ( Wert >= 120 && Wert < 130 ) {     // normal
      return globals.SysDia_normal;
    } else if ( Wert >= 130 && Wert < 140 ) {     // hochnormal
      return globals.SysDia_hochnormal;
    } else if ( Wert >= 140 && Wert < 160 ) {     // Stufe 1
      return globals.SysDia_Stufe_1;
    } else if ( Wert >= 160 && Wert < 180 ) {     // Stufe 2
      return globals.SysDia_Stufe_2;
    } else {                                      // Stufe 3
      return globals.SysDia_Stufe_3;
    }
  }
  Color? Farbe2Systole(int Wert) {
    if ( Wert<120 ) {
    } else if ( Wert >= 120 && Wert < 130 ) {
      return globals.SysDia_optimal_blass;
    } else if ( Wert >= 130 && Wert < 140 ) {
      return globals.SysDia_hochnormal_blass;
    } else if ( Wert >= 140 && Wert < 160 ) {
      return globals.SysDia_Stufe_1_blass;
    } else if ( Wert >= 160 && Wert < 180 ) {
      return globals.SysDia_Stufe_2_blass;
    } else {
      return globals.SysDia_Stufe_3_blass;
    }
  }

  Color Farbe1Diastole(int Wert) {
    if ( Wert<80 ) {
      return globals.SysDia_optimal;
    } else if ( Wert >= 80 && Wert < 85 ) {
      return globals.SysDia_normal;
    } else if ( Wert >= 85 && Wert < 90 ) {
      return globals.SysDia_hochnormal;
    } else if ( Wert >= 90 && Wert < 100 ) {
      return globals.SysDia_Stufe_1;
    } else if ( Wert >= 100 && Wert < 110 ) {
      return globals.SysDia_Stufe_2;
    } else {
      return globals.SysDia_Stufe_3;
    }
  }
  Color? Farbe2Diastole(int Wert) {
    if ( Wert<80 ) {
      return globals.SysDia_optimal_blass;
    } else if ( Wert >= 80 && Wert < 85 ) {
      return globals.SysDia_normal_blass;
    } else if ( Wert >= 85 && Wert < 90 ) {
      return globals.SysDia_hochnormal_blass;
    } else if ( Wert >= 90 && Wert < 100 ) {
      return globals.SysDia_Stufe_1_blass;
    } else if ( Wert >= 100 && Wert < 110 ) {
      return globals.SysDia_Stufe_2_blass;
    } else {
      return globals.SysDia_Stufe_3_blass;
    }
  }

  Color Farbe1Puls(int Wert) {
    if ( Wert > 0 && Wert < 60 ) {
      return globals.Puls_langsam;
    } else if ( Wert >= 60 && Wert < 100 ) {
      return globals.Puls_normal;
    } else {
      return globals.Puls_schnell;
    }
  }
  Color? Farbe2Puls(int Wert) {
    if ( Wert > 0 && Wert < 60 ) {
      return globals.Puls_langsam_blass;
    } else if ( Wert >= 60 && Wert < 100 ) {
      return globals.Puls_normal_blass;
    } else {
      return globals.Puls_schnell_blass;
    }
  }

  Color Farbe1Gewicht(String Wert) {
    if ( Wert.length > 0 ) {
      var w = double.tryParse(Wert);
      if ( w != null && w >= 0.0 ) {
        return globals.Gewicht_normal;
      } else {
        return globals.BgColorNeutral;
      }
    } else {
      return globals.BgColorNeutral;
    }
  }
  Color? Farbe2Gewicht(String Wert) {
    if ( Wert.length > 0 ) {
      var w = double.tryParse(Wert);
      if ( w != null && w >= 0.0 ) {
        return globals.Gewicht_normal_blass;
      } else {
        return globals.BgColorNeutral;
      }
    } else {
      return globals.BgColorNeutral;
    }
  }

  String dasDatum(String Zeitpunkt) {
    if ( Zeitpunkt.length == 0 ) return "kein Datum";
    else return Zeitpunkt.substring(8, 10) + "." + Zeitpunkt.substring(5, 7) + "." + Zeitpunkt.substring(0, 4);
  }

  String dieUhrzeit(String Zeitpunkt) {
    if ( Zeitpunkt.length == 0 ) return "keine Uhrzeit";
    else return Zeitpunkt.substring(11, 19);
  }

  @override
  void initState() {
    super.initState();
    _ladeDaten();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

        // Header
        // ------
        appBar: AppBar(
          title: Text( 'Einträge'),
        ),

        // Body
        // ----
        body: _isLoading
          ? const Center(
            child: CircularProgressIndicator(),
          )
          : Center(
            child: Container(
              width: 350.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverFixedExtentList(
                      itemExtent: 50.0,
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                        return Container(
                          alignment: Alignment.center,
                          color: Colors.grey,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 40, width: 80,
                                child: myListRowWidgetOneLine(isHeader: true, Titel1: "Zeitpunkt", Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: 80, ScaleFactor: 0.75),
                              ),
                              Container(
                                height: 40, width: EntryWidthSysDia,
                                child: myListRowWidgetTwoLines(isHeader: true, Titel1: 'Systole', Titel2: '(mmHg)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: EntryWidthSysDia, ScaleFactor: 0.75),
                              ),
                              Container(
                                height: 40, width: EntryWidthSysDia,
                                child: myListRowWidgetTwoLines(isHeader: true, Titel1: 'Diastole', Titel2: '(mmHg)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: EntryWidthSysDia, ScaleFactor: 0.75),
                              ),
                              Container(
                                height: 40, width: EntryWidthSysDia,
                                child: myListRowWidgetTwoLines(isHeader: true, Titel1: 'Puls', Titel2: '(bps)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: EntryWidthSysDia, ScaleFactor: 0.75),
                              ),
                              Container(
                                height: 40, width: EntryWidthSysDia,
                                child: myListRowWidgetTwoLines(isHeader: true, Titel1: 'Gewicht', Titel2: '(kg)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: EntryWidthSysDia, ScaleFactor: 0.75,),
                              ),
                              Container(
                                height: 40, width: 40,
                                child: Text(""),
                              ),
                            ],
                          ),
                        );
                      },
                        childCount: 1,
                      ),
                    ),

                    // ab hier werden die tatsächlichen Einträge aufgelistet
                    // -----------------------------------------------------
                    SliverFixedExtentList(
                      itemExtent: 60.0,
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                        return Container(
                          //height: 100,
                          alignment: Alignment.center,
                          //color: (index % 2) == 0 ? Colors.grey[200] : Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 40, width: 80,
                                child: myListRowWidgetTwoLines(
                                  isHeader: false,
                                  Titel1: dasDatum(_alleEintraege[index]['Zeitpunkt'].toString()),
                                  Titel2: dieUhrzeit(_alleEintraege[index]['Zeitpunkt'].toString()),
                                  Farbe1: globals.BgColorNeutral,
                                  Farbe2: globals.BgColorNeutral,
                                  Breite: 80,
                                  ScaleFactor: 1.0,),
                              ),
                              Container(
                                height: 40, width: EntryWidthSysDia,
                                child: myListRowWidgetOneLine(
                                  isHeader: false,
                                  Titel1: _alleEintraege[index]['Systole'].toString(),
                                  Farbe1: Farbe1Systole(_alleEintraege[index]['Systole']),
                                  Farbe2: Farbe2Systole(_alleEintraege[index]['Systole']),
                                  Breite: EntryWidthSysDia,
                                  ScaleFactor: 1.0,),
                              ),
                              Container(
                                height: 40, width: EntryWidthSysDia,
                                child: myListRowWidgetOneLine(
                                  isHeader: false,
                                  Titel1: _alleEintraege[index]['Diastole'].toString(),
                                  Farbe1: Farbe1Diastole(_alleEintraege[index]['Diastole']),
                                  Farbe2: Farbe2Diastole(_alleEintraege[index]['Diastole']),
                                  Breite: EntryWidthSysDia,
                                  ScaleFactor: 1.0,),
                              ),
                              Container(
                                height: 40, width: EntryWidthSysDia,
                                child: myListRowWidgetOneLine(
                                  isHeader: false,
                                  Titel1: _alleEintraege[index]['Puls'].toString().isNotEmpty ? _alleEintraege[index]['Puls'].toString() : "---",
                                  Farbe1: _alleEintraege[index]['Puls'].toString().isNotEmpty ? Farbe1Puls(_alleEintraege[index]['Puls']) : globals.BgColorNeutral,
                                  Farbe2: _alleEintraege[index]['Puls'].toString().isNotEmpty ? Farbe2Puls(_alleEintraege[index]['Puls']) : globals.BgColorNeutral,
                                  Breite: EntryWidthSysDia,
                                  ScaleFactor: 1.0,),
                              ),
                              // Container(
                              //   height: 40, width: EntryWidthSysDia,
                              //   child: Text(_alleEintraege[index]['Gewicht'].toString()),
                              // ),
                              Container(
                                height: 40, width: EntryWidthSysDia,
                                child: myListRowWidgetOneLine(
                                  isHeader: false,
                                  Titel1: _alleEintraege[index]['Gewicht'].toString().isNotEmpty && _alleEintraege[index]['Gewicht'] != null ? _alleEintraege[index]['Gewicht'].toString() : "---",
                                  Farbe1: _alleEintraege[index]['Gewicht'].toString().isNotEmpty ? Farbe1Gewicht(_alleEintraege[index]['Gewicht'].toString()) : globals.BgColorNeutral,
                                  Farbe2: _alleEintraege[index]['Gewicht'].toString().isNotEmpty ? Farbe2Gewicht(_alleEintraege[index]['Gewicht'].toString()) : globals.BgColorNeutral,
                                  Breite: EntryWidthSysDia,
                                  ScaleFactor: 1.0,),
                              ),
                              Container(
                                height: 40, width: 40,
                                child: IconButton(
                                  onPressed: (){
                                    int TheID = _alleEintraege[index]['pid'];
                                    if ( TheID == null ) {
                                      TheID = -1;
                                    }
                                    _editItem(index, TheID);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('noch zu programmieren... (index: $index - ID: $TheID)'),
                                        backgroundColor: Color.fromARGB(0xff, 0xbd, 0xbd, 0xbd)
                                      )
                                    );
                                  },
                                  icon: Icon(Icons.edit),
                                  color: Colors.lightBlue,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        );
                        },
                        childCount: _alleEintraege.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Floating Button
        // ---------------
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) =>
                AlertDialog(
                  title: const Text('neuen Eintrag erfassen'),
                  content: Text(
                      "Soll ein neuer Eintrag erfasst werden?"),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context, 'Nein'),
                        child: const Text('Nein')
                    ),
                    TextButton(
                      onPressed: () => _neuerEintrag(),
                      child: const Text('Ja'),
                    ),
                  ],
                ),
            );
          },
          child: Icon(MdiIcons.plus),
          //backgroundColor: Colors.blue,
        ),


        // Footer
        // ------
        persistentFooterButtons: [
          Container(
            width: MediaQuery.of(context).copyWith().size.width,
            color: Colors.lightBlue[100],
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextButton(
                    onPressed: (){},
                    child: Text("Sie sehen \n" + _alleEintraege.length.toString() + " Einträge.",
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    )
                  ),
                ),
                _Limit == -1
                ? Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: (){
                      _Limit = _LimitFromSettings;
                      setState(() {
                        _ladeDaten();
                      });
                    },
                    child: Text("letzte " + _LimitFromSettings.toString() + " anzeigen"),
                  ),
                )
                : Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: (){
                      _Limit = -1;
                      setState(() {
                        _ladeDaten();
                      });
                    },
                    child: Text("alle anzeigen",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class myListRowWidgetOneLine extends StatelessWidget {
  final bool isHeader;
  final String Titel1;
  final Color Farbe1;
  final Color? Farbe2;
  final double Breite;
  final double ScaleFactor;
  const myListRowWidgetOneLine({
    Key? key,required this.isHeader, required this.Titel1, required this.Farbe1, required this.Farbe2, required this.Breite, required this.ScaleFactor
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
              Text(this.Titel1, textScaleFactor: this.ScaleFactor, style: this.ScaleFactor < 1.0 ? TextStyle(fontWeight: FontWeight.bold) : TextStyle(fontWeight: FontWeight.normal),),
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
