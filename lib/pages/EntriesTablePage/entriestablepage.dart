import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sysdiapulsgew/pages/DetailPage/detailpage.dart';
import 'package:sysdiapulsgew/pages/InfoPage/infopage.dart';
import 'package:sysdiapulsgew/pages/SettingsPage/settingspage.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../../my-globals.dart' as globals;
import '../../services/myWidgets.dart' as myWidgets;

class EntriesTablePage extends StatefulWidget {
  const EntriesTablePage({Key? key}) : super(key: key);

  @override
  _EntriesTablePageState createState() => _EntriesTablePageState();
}

class _EntriesTablePageState extends State<EntriesTablePage> {

  bool _isLoading = true;
  int _Limit = -1;
  int _LimitFromSettings = 25;
  int _iAnzEntries = 0;
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
      _iAnzEntries = (await dbHelper.getEntryCount())!;
      _alleEintraege = await dbHelper.getDataItems(_Limit);

      print("_LimitFromSettings=$_LimitFromSettings");
      print("_Limit=$_Limit");
      print("_iAnzEntries=$_iAnzEntries");

      // if ( _LimitFromSettings > _alleEintraege.length ) _LimitFromSettings = _alleEintraege.length;
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

  void _initDaten() async {
    _LimitFromSettings = await dbHelper.getTabEntryCount();
    _iAnzEntries = (await dbHelper.getEntryCount())!;
    if ( _iAnzEntries > 0 ) {
      if ( _iAnzEntries < _LimitFromSettings ) _Limit = _iAnzEntries;
      else _Limit = _LimitFromSettings;
    } else {
      _Limit = 0;
    }
    _ladeDaten();
  }

  String dasDatum(String Zeitpunkt) {
    if ( Zeitpunkt.length == 0 ) return "kein Datum";
    else return Zeitpunkt.substring(8, 10) + "." + Zeitpunkt.substring(5, 7) + "." + Zeitpunkt.substring(0, 4);
  }

  String dieUhrzeit(String Zeitpunkt) {
    if ( Zeitpunkt.length == 0 ) return "keine Uhrzeit";
    else return Zeitpunkt.substring(11, 16);
  }

  @override
  void initState() {
    super.initState();
    _initDaten();
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
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: () {
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const InfoPage(),
                    alignment: Alignment.topCenter,
                    type: PageTransitionType.leftToRightWithFade,),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_sharp),
              onPressed: () {
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const SettingsPage(),
                    alignment: Alignment.topCenter,
                    type: PageTransitionType.leftToRightWithFade,),
                );
              },
            ),
          ],
        ),

        // Body
        // ----
        body: _isLoading
          ? const Center(
            child: CircularProgressIndicator(),
          )
          : Center(
            child: Container(
              width: globals.CardWidth+40,
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
                                child: myWidgets.myListRowWidgetOneLine(isHeader: true, Titel1: "Zeitpunkt", Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: 77, ScaleFactor: 0.75, alignment: Alignment.center),
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
                                          height: 37, width: globals.EntryWidthSysDia,
                                          child: myWidgets.myListRowWidgetTwoLines(isHeader: true, Titel1: 'Systole', Titel2: '(mmHg)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: globals.EntryWidthSysDia, ScaleFactor: 0.75),
                                        ),
                                        Container(
                                          height: 37, width: globals.EntryWidthSysDia,
                                          child: myWidgets.myListRowWidgetTwoLines(isHeader: true, Titel1: 'Diastole', Titel2: '(mmHg)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: globals.EntryWidthSysDia, ScaleFactor: 0.75),
                                        ),
                                        Container(
                                          height: 37, width: globals.EntryWidthSysDia,
                                          child: myWidgets.myListRowWidgetTwoLines(isHeader: true, Titel1: 'Puls', Titel2: '(bpm)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: globals.EntryWidthSysDia, ScaleFactor: 0.75),
                                        ),
                                        Container(
                                          height: 37, width: globals.EntryWidthSysDia,
                                          child: myWidgets.myListRowWidgetTwoLines(isHeader: true, Titel1: 'Gewicht', Titel2: '(kg)', Farbe1: Colors.grey, Farbe2: Colors.grey[500], Breite: globals.EntryWidthSysDia, ScaleFactor: 0.75,),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.zero,
                                    height: 20,
                                    width: globals.EntryWidthSysDia*4,
                                    child: myWidgets.myListRowWidgetOneLine(
                                      isHeader: true,
                                      Titel1: 'Bemerkung',
                                      Farbe1: Colors.grey,
                                      Farbe2: Colors.grey[500],
                                      Breite: globals.EntryWidthSysDia*4,
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
                                  child: myWidgets.myListRowWidgetTwoLines(
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
                                            width: globals.EntryWidthSysDia,
                                            child: myWidgets.myListRowWidgetOneLine(
                                              isHeader: false,
                                              Titel1: _alleEintraege[index]['Systole'].toString(),
                                              Farbe1: globals.Farbe1Systole(_alleEintraege[index]['Systole']),
                                              Farbe2: globals.Farbe2Systole(_alleEintraege[index]['Systole']),
                                              Breite: globals.EntryWidthSysDia,
                                              ScaleFactor: 1.0,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          Container(
                                            //height: 37,
                                            width: globals.EntryWidthSysDia,
                                            child: myWidgets.myListRowWidgetOneLine(
                                              isHeader: false,
                                              Titel1: _alleEintraege[index]['Diastole'].toString(),
                                              Farbe1: globals.Farbe1Diastole(_alleEintraege[index]['Diastole']),
                                              Farbe2: globals.Farbe2Diastole(_alleEintraege[index]['Diastole']),
                                              Breite: globals.EntryWidthSysDia,
                                              ScaleFactor: 1.0,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          Container(
                                            //height: 37,
                                            width: globals.EntryWidthSysDia,
                                            child: myWidgets.myListRowWidgetOneLine(
                                              isHeader: false,
                                              Titel1: _alleEintraege[index]['Puls'].toString().isNotEmpty ? _alleEintraege[index]['Puls'].toString() : "---",
                                              Farbe1: _alleEintraege[index]['Puls'].toString().isNotEmpty ? globals.Farbe1Puls(_alleEintraege[index]['Puls']) : globals.BgColorNeutral,
                                              Farbe2: _alleEintraege[index]['Puls'].toString().isNotEmpty ? globals.Farbe2Puls(_alleEintraege[index]['Puls']) : globals.BgColorNeutral,
                                              Breite: globals.EntryWidthSysDia,
                                              ScaleFactor: 1.0,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          Container(
                                            //height: 37,
                                            width: globals.EntryWidthSysDia,
                                            child: myWidgets.myListRowWidgetOneLine(
                                              isHeader: false,
                                              Titel1: _alleEintraege[index]['Gewicht'].toString().isNotEmpty && _alleEintraege[index]['Gewicht'] != null ? _alleEintraege[index]['Gewicht'].toString() : "---",
                                              Farbe1: _alleEintraege[index]['Gewicht'].toString().isNotEmpty ? globals.Farbe1Gewicht(_alleEintraege[index]['Gewicht'].toString()) : globals.BgColorNeutral,
                                              Farbe2: _alleEintraege[index]['Gewicht'].toString().isNotEmpty ? globals.Farbe2Gewicht(_alleEintraege[index]['Gewicht'].toString()) : globals.BgColorNeutral,
                                              Breite: globals.EntryWidthSysDia,
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
                                      width: globals.EntryWidthSysDia*4,
                                      child: myWidgets.myListRowWidgetOneLine(
                                        isHeader: false,
                                        Titel1: _alleEintraege[index]['Bemerkung'].isNotEmpty && _alleEintraege[index]['Bemerkung'] != null
                                            ? (_alleEintraege[index]['Bemerkung']).length > 27 ? (_alleEintraege[index]['Bemerkung']).substring(0,27) + "...»" : _alleEintraege[index]['Bemerkung']
                                            : "",
                                        Farbe1: globals.BgColorNeutral,
                                        Farbe2: globals.BgColorNeutral,
                                        Breite: 4*globals.EntryWidthSysDia,
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
                    child: Text(_alleEintraege.length.toString() + " von " + _iAnzEntries.toString() + " Einträgen",
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
                      _isLoading = true;
                      _Limit = _LimitFromSettings;
                      setState(() {
                        _ladeDaten();
                      });
                    },
                    child: Text("letzte " + _LimitFromSettings.toString() + " anzeigen",
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : Expanded(
                  flex: 5,
                  child: ElevatedButton(
                    onPressed: (){
                      _isLoading = true;
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
