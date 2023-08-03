import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../../my-globals.dart' as globals;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {

  late BuildContext _context;

  _doRueckfragenImport(BuildContext context, String dateiname) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            elevation: 5.0,
            // backgroundColor: Color.fromRGBO(255, 235, 235, 1),
            title: Container(
              color: Theme.of(context).colorScheme.onError,
              child: Row(
                  children:[
                    // Icon(Icons.priority_high, color: Colors.red,),
                    Container(
                      child: Expanded(
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                          child: Text(
                            "ACHTUNG:\nDiese Aktion kann\nnicht rückgängig\ngemacht werden!",
                            // "ACHTUNG: Diese Aktion kann nicht rückgängig gemacht werden",
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
                    ),
                    // Icon(Icons.priority_high, color: Colors.red,),
                  ]
              ),
            ),
            content: Text(
              "Soll der aktuelle Datenbestand durch den importierten Datenbestand ersetzt werden?",
              textAlign: TextAlign.center,
              softWrap: true,
              textScaleFactor: 2.0,
            ),
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
                        child: const Text('Nein',  textScaleFactor: 2.0,)
                    ),
                    ElevatedButton(
                      // style: ButtonStyle(
                      //   backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
                      // ),
                      onPressed: () async => await _doImportIt(dateiname),
                      child: const Text('Ja',  textScaleFactor: 2.0,),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
  _doSelectImportfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      // type: FileType.custom,
      // allowedExtensions: ['db'],
    );
    if ( result != null && result.files.single.path != null ) {
      PlatformFile file = result.files.first;
      print("${file.name}");
      print("${file.bytes}");
      print("${file.size}");
      print("${file.extension}");
      print("${file.path}");
      print("${file.hashCode}");
      _doRueckfragenImport(_context, "${file.path}");
    }
    setState(() {
      print("Importieren");
    });
  }
  _doImportIt(String dateiname) async  {
    bool ret = await dbHelper.importiereDatenbank(dateiname);
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

  _doRueckfragenExport(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            elevation: 5.0,
            // backgroundColor: Color.fromRGBO(255, 235, 235, 1),
            title: Container(
              // color: Color.fromRGBO(255, 219, 219, 1),
              child: Row(
                  children:[
                    // Icon(Icons.priority_high, color: Colors.red,),
                    Container(
                      child: const Expanded(
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                          child: Text(
                            "Sollen alle Einträge im Download-Ordner des Geräts gesichert werden?",
                            softWrap: true,
                            textAlign: TextAlign.center,
                            textScaleFactor: 2.0,
                            // style: TextStyle(color: Colors.red, ),
                          ),
                        ),
                      ),
                    ),
                    // Icon(Icons.priority_high, color: Colors.red,),
                  ]
              ),
            ),
            content: Text(
              "Es werden alle Einträge und Einstellungen gespeichert.",
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
                      onPressed: () async => await _doExportIt(),
                      child: const Text('Ja'),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
  void _exportiereDatenbank() async {
    bool ret = await dbHelper.exportiereDatenbank();
    if ( ret == true ){
      if ( mounted ) {
        setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datenbank erfolgreich exportiert.'),
            backgroundColor: Color.fromARGB(0xff, 0xbd, 0xbd, 0xbd)
          )
        );
      });
      }
    }
  }
  _doExportIt() async {
    print("Export der Datenbank angestoßen");
    _exportiereDatenbank();
    Navigator.pop(context, 'OK');
    setState(() {
      print("Exportieren");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Import / Export"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50.0,
            ),
            Container(
              width: View.of(context).physicalSize.width * 0.12,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () async {
                  print("Importieren gedrückt");
                  _context = context;
                  print("_context=$_context");
                  await _doSelectImportfile();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Importieren"),
                    const SizedBox(width: 20.0,),
                    Icon(MdiIcons.databaseArrowDown),
                  ],
                )
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            Container(
              width: View.of(context).physicalSize.width * 0.12,
              height: 50.0,
              child: ElevatedButton(
                  onPressed: () async {
                    print("Exportieren gedrückt");
                    _context = context;
                    print("_context=$_context");
                    await _doRueckfragenExport(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Exportieren"),
                      const SizedBox(width: 20.0,),
                      Icon(MdiIcons.databaseArrowUp),
                    ],
                  )
              ),
            ),
          ],
        ),
      )
    );
  }
}
