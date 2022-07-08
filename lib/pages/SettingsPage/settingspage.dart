import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  int _TableEntryCount = 25;
  double _currentSliderValue_TabEntryCount = 20;
  int _DiagramDaysCount = 7;
  double _currentSliderValue_DiagramDaysCount = 7;
  bool _hasChanged = false;

  void _ladeDaten() async {
    _TableEntryCount = await dbHelper.getTabEntryCount();
    _currentSliderValue_TabEntryCount = _TableEntryCount.toDouble();
    _DiagramDaysCount = await dbHelper.getDiagramDaysCount();
    _currentSliderValue_DiagramDaysCount = _DiagramDaysCount.toDouble();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _doSpeichern() async {
    bool _erfolgreich = false;
    try {
      await dbHelper.setTabEntryCount(_currentSliderValue_TabEntryCount.toInt());
      await dbHelper.setDiagramDaysCount(_currentSliderValue_DiagramDaysCount.toInt());
      _erfolgreich = true;
    } on Error catch( _, e ) {
      if (kDebugMode) {
        print( "Fehler in _doSpeichern(): $e");
      }
      _erfolgreich = true;
    }
    if (_erfolgreich == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Änderungen gespeichert.'), backgroundColor: Colors.green));
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
            actions: [
              Visibility(
                visible: _hasChanged,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    onPressed: () async {
                      _doSpeichern();
                    },
                    child: Row(
                      children: const [
                        Text('übernehmen'),
                        Icon(MdiIcons.checkBold),
                      ],
                    )),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Anzahl sichtbarer Einträge in der Liste",
                            textScaleFactor: 1.3,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 10,
                                child: Slider(
                                    value: _currentSliderValue_TabEntryCount,
                                    min: 5,
                                    max: 100,
                                    divisions: 19,
                                    label: _currentSliderValue_TabEntryCount.round().toString(),
                                    onChanged: (double value) {
                                      setState(() {
                                        _currentSliderValue_TabEntryCount = value;
                                        _hasChanged = true;
                                      });
                                    }),
                              ),
                              Flexible(flex: 1, child: Text("${_currentSliderValue_TabEntryCount.round()}", textScaleFactor: 1.7)),
                            ],
                          ),
                          SizedBox(height: 25,),
                          const Text(
                            "Anzahl berücksichtigter Tage im Diagramm",
                            textScaleFactor: 1.3,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 10,
                                child: Slider(
                                    value: _currentSliderValue_DiagramDaysCount,
                                    min: 7,
                                    max: 91,
                                    divisions: 12,
                                    label: _currentSliderValue_DiagramDaysCount.round().toString(),
                                    onChanged: (double value) {
                                      setState(() {
                                        _currentSliderValue_DiagramDaysCount = value;
                                        _hasChanged = true;
                                      });
                                    }),
                              ),
                              Flexible(flex: 1, child: Text("${_currentSliderValue_DiagramDaysCount.round()}", textScaleFactor: 1.7)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
    ));
  }
}
