import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../../my-globals.dart' as globals;

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
      if ( await Directory(globals.lokalDBPfad).exists() == true ) {
        _dirExists = true;
        final List<FileSystemEntity> entities = await Directory(
            globals.lokalDBPfad)
            .list(recursive: false, followLinks: false)
            .toList();
        Iterable<File> dateien = entities.whereType<File>();
        dateiNamen.clear();
        dateiDaten.clear();
        dateien.forEach((element) {
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
    setState(() {
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
      setState(() {
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
    Navigator.pop(context, 'OK');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(strDBName + " erfolgreich importiert."),
            backgroundColor: Color.fromARGB(0xff, 0xbd, 0xbd, 0xbd)
        )
    );
  }

  void _onItemTapped(int i1, int i2) {
    if ( i1 == 0 ) {            // Datenbank laden
      _doImport(dateiNamen[i2]);
    } else if ( i1 == 1 ) { // Datenbank löschen
      String _strAusgabe = i1 == 0 ? 'Datenbank laden' : 'Datenbank löschen';
      _strAusgabe += ': ' + dateiNamen[i2];
      setState(() {
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
          : ListView.builder(
            itemCount: dateiNamen.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(dateiNamen[index]),
              subtitle: Text(dateiDaten[index]),
              leading: SizedBox(
                width: 50,
                child: const Icon(MdiIcons.database)     // heartHalfFull
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                        showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                        AlertDialog(
                          title: const Text("ACHTUNG: kann nicht rückgängig gemacht werden!"),
                          content: Text("Soll der aktuelle Datenbestand durch den importierten Datenbestand ersetzt werden?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Nein'),
                              child: const Text('Nein')
                            ),
                            TextButton(
                              onPressed: () => _doImport(dateiNamenVoll[index]),
                              child: const Text('Ja'),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(Icons.arrow_downward_outlined)
                    ),
                    IconButton(
                        onPressed: () => _onItemTapped(1, index),
                        icon: const Icon(Icons.delete)
                    ),
                  ],
                ),
              ),
            )
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
