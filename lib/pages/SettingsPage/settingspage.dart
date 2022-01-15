import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../my-globals.dart' as globals;
import 'package:sysdiapulsgew/services/dbhelper.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  int _LimitFromSettings = 25;
  double _currentSliderValue = 20;

  void _ladeDaten() async {
    _LimitFromSettings = await dbHelper.getTabEntryCount();
    _currentSliderValue = _LimitFromSettings.toDouble();
    if ( mounted ) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _doAbbrechen() async {
    // kehrt zur Liste der Einträge zurück
    Navigator.pop(context);
  }

  void _doSpeichern() async {
    if ( await dbHelper.setTabEntryCount( _currentSliderValue.toInt() ) == true ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Änderungen gespeichert.'),
          backgroundColor: Colors.green
        )
      );
      // kehrt zur Liste der Einträge zurück
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _ladeDaten();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Einstellungen"),
          ),
          body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
              child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("Anzahl Einträge in der Liste", textScaleFactor: 1.7,),
                    Slider(
                      value: _currentSliderValue,
                      min: 5,
                      max: 100,
                      divisions: 19,
                      label: _currentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      }
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(onPressed: () => _doSpeichern(), child: Text("speichern")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ),
      )
    );
  }
}
