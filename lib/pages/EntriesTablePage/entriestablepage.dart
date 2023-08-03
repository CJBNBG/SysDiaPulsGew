import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sysdiapulsgew/pages/DetailPage/detailpage.dart';
import 'package:sysdiapulsgew/pages/InfoPage/infopage.dart';
import 'package:sysdiapulsgew/pages/SettingsPage/settingspage.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../../my-globals.dart' as globals;
import '../../myUpdateProvider.dart';
import '../../services/DataInterface.dart';
import '../../services/myWidgets.dart' as myWidgets;
import 'package:sysdiapulsgew/services/screenhelper.dart';

import '../DailyEntriesTablePage/dailyentriestablepage.dart';

double _scaleFactor = 1.0;
// int _Bemlen = 1;
double _BreiteZeitpunkt = 1.0;
// double _hoeheUberschrift = 1.0;

bool _isLoading = true;
int _Limit = -1;
int _LimitFromSettings = 25;
int _iAnzEntries = 0;
List<Map<String, dynamic>> _alleEintraege = [];

class EntriesTablePage extends StatefulWidget {
  const EntriesTablePage({Key? key}) : super(key: key);

  @override
  _EntriesTablePageState createState() => _EntriesTablePageState();
}

class _EntriesTablePageState extends State<EntriesTablePage> {

  _deleteItem(BuildContext context, int ndx) async {
    int id = _alleEintraege[ndx][DataInterface.colID];
    if (id != null) {
      await dbHelper.deleteDataItem(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eintrag gelöscht')),
      );
      // setState(() {
      //   _ladeDaten();
      //   globals.updAVG_needed = true;
      // });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim löschen ($id)')),
      );
    }
    _isLoading = true;
    await _initDaten();
  }

  _editItem(BuildContext context, int ndx) async {
    int id = _alleEintraege[ndx][DataInterface.colID];
    if (id == null) {
      id = -1;
    }
    globals.aktID = id;
    await Navigator.push(
      context,
      PageTransition(
        child: const DetailPage(),
        alignment: Alignment.topCenter,
        type: PageTransitionType.leftToRightWithFade,
      ),
    );
    _isLoading = true;
    await _initDaten();
  }

  _frageLoeschen(BuildContext context, int index) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        elevation: 5.0,
        // backgroundColor: Color.fromRGBO(255, 235, 235, 1),
        title: Container(
          color: Theme.of(context).colorScheme.onError,
          child: Row(children: [
            // Icon(Icons.priority_high, color: Colors.red,),
            Expanded(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                child: Text(
                  "ACHTUNG:\nDiese Aktion kann\nnicht rückgängig\ngemacht werden!",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  textScaleFactor: 2.0,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Icon(Icons.priority_high, color: Colors.red,),
          ]),
        ),
        content: const Text(
          "Möchten Sie diesen Eintrag wirklich löschen?",
          textAlign: TextAlign.center,
          softWrap: true,
          textScaleFactor: 2.0,
        ),
        actions: <Widget>[
          // SizedBox(width: 20.0,),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    // style: ButtonStyle(
                    //   backgroundColor: MaterialStateProperty.all(Colors.green[100]),/8/8+9
                    // ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Nein', textScaleFactor: 2.0,)),
                ElevatedButton(
                  // style: ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
                  // ),
                  onPressed: () async {
                    await _deleteItem(context, index);
                    await _initDaten();
                    Navigator.pop(context);
                  },
                  child: const Text('Ja',  textScaleFactor: 2.0,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _neuerEintrag(BuildContext context) async {
    globals.aktID = -1;
    Navigator.pop(context, 'OK');
    await Navigator.push(
      context,
      PageTransition(
        child: const DetailPage(),
        alignment: Alignment.topCenter,
        type: PageTransitionType.leftToRightWithFade,
      ),
    );
    _isLoading = true;
    await _initDaten();
  }

  _ladeDaten() async {
    try {
      _iAnzEntries = (await dbHelper.getEntryCount())!;
      _alleEintraege = await dbHelper.getDataItems(_Limit);

      print("_LimitFromSettings=$_LimitFromSettings");
      print("_Limit=$_Limit");
      print("_iAnzEntries=$_iAnzEntries");

      // if ( _LimitFromSettings > _alleEintraege.length ) _LimitFromSettings = _alleEintraege.length;
    } on Error catch (_, e) {
      print("Fehler in _ladeDaten(): $e");
    }
  }

  _initDaten() async {
    try {
      _LimitFromSettings = await dbHelper.getTabEntryCount();
      _iAnzEntries = (await dbHelper.getEntryCount())!;
      if (_iAnzEntries > 0) {
        if (_iAnzEntries < _LimitFromSettings) {
          _Limit = _iAnzEntries;
        } else {
          _Limit = _LimitFromSettings;
        }
      } else {
        _Limit = 0;
      }
      await _ladeDaten();
      setState(() {
        globals.updAVG_needed = true;
        _isLoading = false;
      });
    } on Error catch (_, e) {
      print("Fehler in _initDaten(): $e");
    }
  }

  String dasDatum(String Zeitpunkt) {
    if (Zeitpunkt.isEmpty)
      return "kein Datum";
    else {
      return "${Zeitpunkt.substring(8, 10)}.${Zeitpunkt.substring(5, 7)}.${Zeitpunkt.substring(0, 4)}";
    }
  }

  String dieUhrzeit(String Zeitpunkt) {
    if (Zeitpunkt.isEmpty)
      return "keine Uhrzeit";
    else {
      return Zeitpunkt.substring(11, 16);
    }
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
    // bool isLandscape = Screen.isLandscape(context);
    // bool isLargePhone = Screen.diagonal(context) > 720;
    // bool isNarrow = Screen.widthInches(context) < 3.5;
    // bool isTablet = Screen.diagonalInches(context) >= 8.5; // war 7s
    _BreiteZeitpunkt = Screen.width(context) / 3.0;

    return SafeArea(
      child: Scaffold(
        // Header
        // ------
        appBar: AppBar(
          backgroundColor: globals.CardColor,
          elevation: 4.0,
          title: Text('Einträge'),
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
                    type: PageTransitionType.leftToRightWithFade,
                  ),
                );
              },
            ),
            // IconButton(
            //   icon: const Icon(Icons.calendar_month),
            //   onPressed: () {
            //     //Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       PageTransition(
            //         child: const dailyEntriesTablePage(),
            //         alignment: Alignment.topCenter,
            //         type: PageTransitionType.leftToRightWithFade,
            //       ),
            //     );
            //   },
            // ),
          ],
        ),

        // Body
        // ----
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      // alignment: Alignment.center,
                      color: globals.CardColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Headerzeile
                          // -----------------------------------------------------
                          Flexible(
                              flex: 1,
                              child: myWidgets.myListRowWidgetOneLine(
                                  isHeader: true,
                                  Titel1: "Zeitpunkt",
                                  Farbe1: globals.CardColor,
                                  Farbe2: globals.CardColor,
                                  Breite: _BreiteZeitpunkt,
                                  ScaleFactor: _scaleFactor,
                                  alignment: Alignment.center)),
                          Flexible(
                            flex: 2,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      myWidgets.myListRowWidgetTwoLines(
                                        isHeader: true,
                                        Titel1: 'Systole',
                                        Titel2: '(mmHg)',
                                        Farbe1: globals.CardColor,
                                        Farbe2: globals.CardColor,
                                        Breite: _BreiteZeitpunkt / 2.0,
                                        ScaleFactor: _scaleFactor,
                                        Padding: 0.0,
                                      ),
                                      myWidgets.myListRowWidgetTwoLines(
                                        isHeader: true,
                                        Titel1: 'Diastole',
                                        Titel2: '(mmHg)',
                                        Farbe1: globals.CardColor,
                                        Farbe2: globals.CardColor,
                                        Breite: _BreiteZeitpunkt / 2.0,
                                        ScaleFactor: _scaleFactor,
                                        Padding: 0.0,
                                      ),
                                      myWidgets.myListRowWidgetTwoLines(
                                        isHeader: true,
                                        Titel1: 'Puls',
                                        Titel2: '(bpm)',
                                        Farbe1: globals.CardColor,
                                        Farbe2: globals.CardColor,
                                        Breite: _BreiteZeitpunkt / 2.0,
                                        ScaleFactor: _scaleFactor,
                                        Padding: 0.0,
                                      ),
                                      myWidgets.myListRowWidgetTwoLines(
                                        isHeader: true,
                                        Titel1: 'Gewicht',
                                        Titel2: '(kg)',
                                        Farbe1: globals.CardColor,
                                        Farbe2: globals.CardColor,
                                        Breite: _BreiteZeitpunkt / 2.0,
                                        ScaleFactor: _scaleFactor,
                                        Padding: 0.0,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                  child: Container(
                                    color: Colors.black54,
                                  ),
                                ),
                                Container(
                                  color: globals.CardColor,
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: 1.5,
                                          child: Text(
                                            'Pulsdruck (mmHg)',
                                            style: TextStyle(
                                              fontSize: 10.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.all(0.0),
                                          child: Text(' '),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerRight,
                                          widthFactor: 0.75,
                                          child: Text(
                                            'BMI',
                                            style: TextStyle(
                                              fontSize: 10.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: myWidgets.myListRowWidgetOneLine(
                                    isHeader: true,
                                    Titel1: 'Bemerkung',
                                    Farbe1: globals.CardColor,
                                    Farbe2: globals.CardColor,
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
                  ),
                  Flexible(
                    flex: 6,
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : CustomScrollView(
                            slivers: <Widget>[
                              // ab hier werden die tatsächlichen Einträge aufgelistet
                              // -----------------------------------------------------
                              SliverFixedExtentList(
                                  itemExtent: globals.EntryHeight, // noch verbesserungsfähig!!!!!!
                                  delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () async {
                                        await _editItem(context, index);
                                      },
                                      onDoubleTap: () async {
                                        await _frageLoeschen(context, index);
                                      },
                                      child: myWidgets.datenZeile(
                                        Zeitpunkt: _alleEintraege[index]['Zeitpunkt'],
                                        Systole: _alleEintraege[index]['Systole'],
                                        Diastole: _alleEintraege[index]['Diastole'],
                                        Puls: _alleEintraege[index]['Puls'],
                                        Gewicht: _alleEintraege[index]['Gewicht'],
                                        Bemerkung: _alleEintraege[index]['Bemerkung'],
                                      ),
                                    );
                                  }, childCount: _alleEintraege.length)),
                            ],
                          ),
                  ),
                ],
              ),

        // Floating Button
        // ---------------
        floatingActionButton: FloatingActionButton(
          backgroundColor: globals.CardColor,
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('neuen Eintrag erfassen'),
                content: const Text("Soll ein neuer Eintrag erfasst werden?"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, 'Nein');
                      },
                      child: const Text('Nein')),
                  TextButton(
                    onPressed: () {
                      _neuerEintrag(context);
                    },
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
            height: 50.0,
            color: globals.CardColor,
            // color: Colors.lightBlue[100],
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    "Sie sehen ${_alleEintraege.length} von $_iAnzEntries Einträgen.",
                    style: const TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                // _Limit == -1
                //     ? Expanded(
                //         flex: 5,
                //         child: ElevatedButton(
                //           onPressed: () async {
                //             _isLoading = true;
                //             await _initDaten();
                //           },
                //           child: Text(
                //             "letzte $_LimitFromSettings anzeigen",
                //             textAlign: TextAlign.center,
                //           ),
                //         ),
                //       )
                //     : Expanded(
                //         flex: 5,
                //         child: ElevatedButton(
                //           onPressed: () async {
                //             _isLoading = true;
                //             await _initDaten();
                //           },
                //           child: const Text(
                //             "alle anzeigen",
                //             textAlign: TextAlign.center,
                //           ),
                //         ),
                //       )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
