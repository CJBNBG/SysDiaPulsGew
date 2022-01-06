import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sysdiapulsgew/pages/DetailPage/detailpage.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../../my-globals.dart' as globals;

const EntryWidthSysDia = 55.0;

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

  void _deleteItem(int ndx) async {
    int id = _alleEintraege[ndx]['pid'];
    if ( id != null ) {
      await dbHelper.deleteDataItem(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eintrag gelöscht')),
      );
      setState(() {
        _ladeDaten();
        globals.updAVG_needed = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim löschen ($id)')),
      );
    }
  }

  void _editItem(int ndx) async {
    int id = _alleEintraege[ndx]['pid'];
    if ( id == null ) {
      id = -1;
    }
    globals.aktID = id;
    await Navigator.push(
      context,
      PageTransition(
        child: DetailPage(),
        alignment: Alignment.topCenter,
        type: PageTransitionType.leftToRightWithFade,),
    );
    setState(() {
      _ladeDaten();
      globals.updAVG_needed = true;
    });
  }

  void _ladeDaten() async {
    try {
      _LimitFromSettings = await dbHelper.getTabEntryCount();
      // _alleEintraege.clear();
      _alleEintraege = await dbHelper.getDataItems(_Limit);
      if ( _LimitFromSettings > _alleEintraege.length ) _LimitFromSettings = _alleEintraege.length;
    } on Error catch( _, e ) {
      print("Fehler in _ladeDaten(): $e");
    }
    if ( mounted ) setState(() {
      _isLoading = false;
    });
  }

  void _neuerEintrag() async {
    globals.aktID = -1;
    Navigator.pop(context, 'OK');
    await Navigator.push(
      context,
      PageTransition(
        child: DetailPage(),
        alignment: Alignment.topCenter,
        type: PageTransitionType.leftToRightWithFade,),
    );
    setState(() {
      _ladeDaten();
    });
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
      return globals.SysDia_optimal_blass;
    } else if ( Wert >= 120 && Wert < 130 ) {
      return globals.SysDia_normal_blass;
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
  void dispose() {
    super.dispose();
    globals.updAVG_needed = true;
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
                      itemExtent: 64.0,
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.zero,
                          alignment: Alignment.center,
                          color: Colors.grey,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 60,
                                margin: EdgeInsets.zero,
                                color: Colors.grey[400],
                                child: myListRowWidgetOneLine(isHeader: true, Titel1: "Zeitpunkt", Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: 77, ScaleFactor: 0.75, alignment: Alignment.center),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.topCenter,
                                    height: 40,
                                    margin: EdgeInsets.zero,
                                    color: Colors.grey[300],
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 37, width: EntryWidthSysDia,
                                          child: myListRowWidgetTwoLines(isHeader: true, Titel1: 'Systole', Titel2: '(mmHg)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: EntryWidthSysDia, ScaleFactor: 0.75),
                                        ),
                                        Container(
                                          height: 37, width: EntryWidthSysDia,
                                          child: myListRowWidgetTwoLines(isHeader: true, Titel1: 'Diastole', Titel2: '(mmHg)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: EntryWidthSysDia, ScaleFactor: 0.75),
                                        ),
                                        Container(
                                          height: 37, width: EntryWidthSysDia,
                                          child: myListRowWidgetTwoLines(isHeader: true, Titel1: 'Puls', Titel2: '(bps)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: EntryWidthSysDia, ScaleFactor: 0.75),
                                        ),
                                        Container(
                                          height: 37, width: EntryWidthSysDia,
                                          child: myListRowWidgetTwoLines(isHeader: true, Titel1: 'Gewicht', Titel2: '(kg)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: EntryWidthSysDia, ScaleFactor: 0.75,),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.zero,
                                    height: 20,
                                    width: EntryWidthSysDia*4,
                                    child: myListRowWidgetOneLine(
                                      isHeader: true,
                                      Titel1: 'Bemerkung',
                                      Farbe1: Colors.grey,
                                      Farbe2: Colors.grey[500],
                                      Breite: EntryWidthSysDia*4,
                                      ScaleFactor: 0.75,
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                        childCount: 1,                      // nur eine Überschriftenzeile
                      ),
                    ),

                    // ab hier werden die tatsächlichen Einträge aufgelistet
                    // -----------------------------------------------------
                    SliverFixedExtentList(
                      itemExtent: 64.0,
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                        return Slidable(
                          child: Container(
                            margin: EdgeInsets.zero,
                            alignment: Alignment.center,
                            color: Colors.grey[400],
                            //height: 100,
                            //color: (index % 2) == 0 ? Colors.grey[300] : globals.BgColorNeutral,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 62,
                                  child: myListRowWidgetTwoLines(
                                    isHeader: false,
                                    Titel1: dasDatum(_alleEintraege[index]['Zeitpunkt'].toString()),
                                    Titel2: dieUhrzeit(_alleEintraege[index]['Zeitpunkt'].toString()),
                                    Farbe1: globals.BgColorNeutral,
                                    Farbe2: globals.BgColorNeutral,
                                    Breite: 80,
                                    ScaleFactor: 1.0,),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topCenter,
                                      height: 40,
                                      margin: EdgeInsets.zero,
                                      child: Row(
                                        children: [
                                          Container(
                                            //height: 37,
                                            width: EntryWidthSysDia,
                                            child: myListRowWidgetOneLine(
                                              isHeader: false,
                                              Titel1: _alleEintraege[index]['Systole'].toString(),
                                              Farbe1: Farbe1Systole(_alleEintraege[index]['Systole']),
                                              Farbe2: Farbe2Systole(_alleEintraege[index]['Systole']),
                                              Breite: EntryWidthSysDia,
                                              ScaleFactor: 1.0,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          Container(
                                            //height: 37,
                                            width: EntryWidthSysDia,
                                            child: myListRowWidgetOneLine(
                                              isHeader: false,
                                              Titel1: _alleEintraege[index]['Diastole'].toString(),
                                              Farbe1: Farbe1Diastole(_alleEintraege[index]['Diastole']),
                                              Farbe2: Farbe2Diastole(_alleEintraege[index]['Diastole']),
                                              Breite: EntryWidthSysDia,
                                              ScaleFactor: 1.0,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          Container(
                                            //height: 37,
                                            width: EntryWidthSysDia,
                                            child: myListRowWidgetOneLine(
                                              isHeader: false,
                                              Titel1: _alleEintraege[index]['Puls'].toString().isNotEmpty ? _alleEintraege[index]['Puls'].toString() : "---",
                                              Farbe1: _alleEintraege[index]['Puls'].toString().isNotEmpty ? Farbe1Puls(_alleEintraege[index]['Puls']) : globals.BgColorNeutral,
                                              Farbe2: _alleEintraege[index]['Puls'].toString().isNotEmpty ? Farbe2Puls(_alleEintraege[index]['Puls']) : globals.BgColorNeutral,
                                              Breite: EntryWidthSysDia,
                                              ScaleFactor: 1.0,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          Container(
                                            //height: 37,
                                            width: EntryWidthSysDia,
                                            child: myListRowWidgetOneLine(
                                              isHeader: false,
                                              Titel1: _alleEintraege[index]['Gewicht'].toString().isNotEmpty && _alleEintraege[index]['Gewicht'] != null ? _alleEintraege[index]['Gewicht'].toString() : "---",
                                              Farbe1: _alleEintraege[index]['Gewicht'].toString().isNotEmpty ? Farbe1Gewicht(_alleEintraege[index]['Gewicht'].toString()) : globals.BgColorNeutral,
                                              Farbe2: _alleEintraege[index]['Gewicht'].toString().isNotEmpty ? Farbe2Gewicht(_alleEintraege[index]['Gewicht'].toString()) : globals.BgColorNeutral,
                                              Breite: EntryWidthSysDia,
                                              ScaleFactor: 1.0,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.zero,
                                      height: 22,
                                      width: EntryWidthSysDia*4,
                                      child: myListRowWidgetOneLine(
                                        isHeader: false,
                                        Titel1: _alleEintraege[index]['Bemerkung'].isNotEmpty && _alleEintraege[index]['Bemerkung'] != null
                                            ? (_alleEintraege[index]['Bemerkung']).length > 27 ? (_alleEintraege[index]['Bemerkung']).substring(0,27) + "...»" : _alleEintraege[index]['Bemerkung']
                                            : "",
                                        Farbe1: globals.BgColorNeutral,
                                        Farbe2: globals.BgColorNeutral,
                                        Breite: 4*EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        alignment: Alignment.centerLeft,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          startActionPane: ActionPane(
                            // A motion is a widget used to control how the pane animates.
                            motion: const ScrollMotion(),
                            // All actions are defined in the children parameter.
                            children: [
                              // A SlidableAction can have an icon and/or a label.
                              SlidableAction(
                                onPressed: (context) => {
                                  _editItem(index)
                                },
                                backgroundColor: Color(0xFF21B7CA),
                                foregroundColor: globals.BgColorNeutral,
                                icon: Icons.edit,
                                label: 'editieren',
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            // A motion is a widget used to control how the pane animates.
                            motion: const ScrollMotion(),
                            // All actions are defined in the children parameter.
                            children: [
                              SlidableAction(
                                onPressed: (context) => {
                                  _deleteItem(index)
                                },
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: globals.BgColorNeutral,
                                icon: Icons.delete,
                                label: 'löschen',
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
                _Limit == -1 && _alleEintraege.length > 0
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
