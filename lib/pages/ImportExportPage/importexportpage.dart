import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../../my-globals.dart' as globals;
import 'package:flutter_slidable/flutter_slidable.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({Key? key}) : super(key: key);

  @override
  _ImportExportPageState createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {

  bool _dirExists = false;
  bool _isLoading = true;
  List<String> dateiNamen = [];
  List<String> dateiDaten = [];
  List<String> dateiNamenVoll = [];
  String dateiName = '';
  String dateiDatum = '';
  String strJahr = '';
  String strMonat = '';
  String strTag = '';
  String strStunde = '';
  String strMinute = '';

  void ladeDateien() async {
    try {
      if ( await Directory(globals.lokalDBPfad).exists() == false ) {
        print("Verzeichnis ${globals.lokalDBPfad} nicht gefunden...");
        var resDir = await Directory(globals.lokalDBPfad).create(recursive: true);
        if ( resDir.isAbsolute ) {
          if (kDebugMode) {
            print("...erzeugt");
            print("resDir.uri.userInfo=" + resDir.uri.userInfo);
          }
        }
      }
      if ( await Directory(globals.lokalDBPfad).exists() == true ) {
        print("Verzeichnis ${globals.lokalDBPfad} gefunden");
        _dirExists = true;
        final List<FileSystemEntity> entities = await Directory(
          globals.lokalDBPfad).list(recursive: false, followLinks: false).toList();
        print(entities);
        var reversedList = entities.reversed.toList();
        Iterable<File> dateien = reversedList.whereType<File>();
        dateiNamen.clear();
        dateiDaten.clear();
        dateien.forEach((element) {
          print(element);
          dateiName = element.uri.pathSegments.last;
          dateiNamenVoll.add(dateiName);
          if (dateiName.contains(globals.lokalDBNameOhnePfad)) {
            strJahr = dateiName.substring(0, 4);
            strMonat = dateiName.substring(4, 6);
            strTag = dateiName.substring(6, 8);
            strStunde = dateiName.substring(9, 11);
            strMinute = dateiName.substring(11, 13);
            dateiNamen.add(dateiName
                .split('_')
                .last);
            dateiDaten.add(
                strTag + '.' + strMonat + '.' + strJahr + ' ' + strStunde +
                    ':' +
                    strMinute);
          }
        });
      } else {
        _dirExists = false;
        print("Das Verzeichnis für die exportierten Datenbanken existiert nicht: " + globals.lokalDBPfad);
      }
    } on Error catch( _, e ) {
      print("keine Dateien gefunden");
    }
    if ( mounted ) setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    ladeDateien();
  }

  void _doExport() {
    _exportiereDatenbank();
    Navigator.pop(context, 'OK');
  }

  void _exportiereDatenbank() async {
    bool ret = await dbHelper.exportiereDatenbank();
    if ( ret == true ){
      if ( mounted ) setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datenbank erfolgreich exportiert.'),
            backgroundColor: Color.fromARGB(0xff, 0xbd, 0xbd, 0xbd)
          )
        );
        ladeDateien();
      });
    }
  }

  void _doImport(String strDBName) async {
    bool ret = await dbHelper.importiereDatenbank(strDBName);
    if ( ret == true ) {
      globals.updAVG_needed = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("erfolgreich importiert"),
          backgroundColor: Colors.green
        )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("NICHT erfolgreich importiert!!!"),
          backgroundColor: Colors.red
        )
      );
    }
    Navigator.pop(context, 'OK');
  }

  void _onItemTapped(int i1, int i2) {
    if ( i1 == 0 ) {            // Datenbank laden
      _doImport(dateiNamen[i2]);
    } else if ( i1 == 1 ) { // Datenbank löschen
      String _strAusgabe = i1 == 0 ? 'Datenbank laden' : 'Datenbank löschen';
      _strAusgabe += ': ' + dateiNamen[i2];
      if ( mounted ) setState(() {
        // ...
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_strAusgabe),
            backgroundColor: Color.fromARGB(0xff, 0xbd, 0xbd, 0xbd)
          )
        );
      });
    }
  }

  _doLoeschen(BuildContext context, int ndx) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("löschen - index: $ndx"),
        backgroundColor: Color.fromARGB(0xff, 0xbd, 0xbd, 0xbd)
      )
    );
  }

  doImportieren(BuildContext context, int index) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
      AlertDialog(
        elevation: 5.0,
        // backgroundColor: Color.fromRGBO(255, 235, 235, 1),
        title: Container(
          color: Color.fromRGBO(255, 219, 219, 1),
          child: Row(
            children:[
              // Icon(Icons.priority_high, color: Colors.red,),
              Container(
                child: const Expanded(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.center,
                    child: Text(
                      "ACHTUNG:\nDiese Aktion kann\nnicht rückgängig\ngemacht werden!",
                      // "ACHTUNG: Diese Aktion kann nicht rückgängig gemacht werden",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      textScaleFactor: 2.0,
                      style: TextStyle(color: Colors.red, ),
                    ),
                  ),
                ),
              ),
              // Icon(Icons.priority_high, color: Colors.red,),
            ]
          ),
        ),
        content: Text(
          "Soll der aktuelle Datenbestand durch den importierten Datenbestand ersetzt werden?",
          textAlign: TextAlign.center,
          softWrap: true,),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  // style: ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(Colors.green[100]),/8/8+9
                  // ),
                    onPressed: () => Navigator.pop(context, 'Nein'),
                    child: const Text('Nein')
                ),
                ElevatedButton(
                  // style: ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
                  // ),
                  onPressed: () => _doImport(dateiNamenVoll[index]),
                  child: const Text('Ja'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text( 'Import / Export'),
        ),
        body: _isLoading
          ? const Center(
            child: CircularProgressIndicator(),
            )
          : Center(
            child: Container(
              width: globals.CardWidth,
              child: Card(
                elevation: 5.0,
                child: ListView.builder(
                  itemCount: dateiNamen.length,
                  itemBuilder: (context, index) => Slidable(
                    startActionPane: ActionPane(
                      // A motion is a widget used to control how the pane animates.
                      motion: const ScrollMotion(),
                      // All actions are defined in the children parameter.
                      children: [
                        // A SlidableAction can have an icon and/or a label.
                        SlidableAction(
                          onPressed: (context) => {
                            doImportieren(context, index)
                          },
                          backgroundColor: Color(0xFF21B7CA),
                          foregroundColor: globals.BgColorNeutral,
                          icon: MdiIcons.arrowDown,
                          label: 'importieren',
                          flex: 2,
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
                            _doLoeschen(context, index)
                          },
                          backgroundColor: Color(0xFFFE4A49),
                          foregroundColor: globals.BgColorNeutral,
                          icon: Icons.delete,
                          label: 'löschen',
                          flex: 4,
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(dateiNamen[index]),
                      subtitle: Text(dateiDaten[index]),
                      leading: SizedBox(
                        width: 50,
                        child: const Icon(MdiIcons.database)     // heartHalfFull
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if ( _dirExists ) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                    AlertDialog(
                      title: const Text('aktuelle Datenbank exportieren'),
                      content: Text(
                          "Soll der aktuelle Datenbestand gesichert werden?"),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.pop(context, 'Nein'),
                            child: const Text('Nein')
                        ),
                        TextButton(
                          onPressed: () => _doExport(),
                          child: const Text('Ja'),
                        ),
                      ],
                    ),
              );
            }
          },
          child: _dirExists ? Icon(MdiIcons.databasePlus) : null,
          //backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
