import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sysdiapulsgew/myUpdateProvider.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../../my-globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:sysdiapulsgew/services/screenhelper.dart';

double _padding_left = 25.0;
double _padding_right = 25.0;
double _padding_top = 25.0;
double _padding_bottom = 25.0;
int _flexval = 6;
bool _hasChanged = false;

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _datensatz = [];
  int aktID = -1;

  TextEditingController ctrSystole = TextEditingController();
  TextEditingController ctrDiastole = TextEditingController();
  TextEditingController ctrPuls = TextEditingController();
  TextEditingController ctrGewicht = TextEditingController();
  String _neuerZeitpunkt = '';
  String _neueSystole = '';
  String _neueDiastole = '';
  String _neuerPulsdruck = '';
  String _neuerPuls = '';
  String _neuesGewicht = '';
  String _neueBemerkung = '';

  _aendereDatensatz() async {
    _formKey.currentState?.save();
    int id = globals.aktID;
    int? Systole = int.tryParse(_neueSystole);
    int? Diastole = int.tryParse(_neueDiastole);
    int? Puls = int.tryParse(_neuerPuls);
    String Zeitpunkt = _neuerZeitpunkt;
    double? Gewicht = double.tryParse(_neuesGewicht);
    String Bemerkung = _neueBemerkung;
    int result = -1;

    if (globals.aktID == -1) {
      result = await dbHelper.createDataItem(Zeitpunkt, Systole!, Diastole!, Puls, Gewicht, Bemerkung);
    } else {
      result = await dbHelper.updateDataItem(id, Systole!, Diastole!, Puls!, Zeitpunkt, Gewicht, Bemerkung);
    }
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: globals.aktID == -1 ? Text('Eintrag gespeichert') : Text('Änderungen gespeichert'),
          backgroundColor: Colors.green));
      // kehrt zur Liste der Einträge zurück
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler beim Speichern!'), backgroundColor: Colors.red));
    }
  }

  void _ladeDaten() async {
    aktID = globals.aktID;
    if (globals.aktID == -1) {
      int? iAnz = await dbHelper.getEntryCount();
      if (iAnz! > 0) {
        final neueDaten = await dbHelper.getLastEntry();
        if (kDebugMode) {
          print(neueDaten);
        }
        _neuerZeitpunkt = globals.zeitpunktNeuerEintrag;
        _neueSystole = neueDaten[0]['Systole'].toString();
        _neueDiastole = neueDaten[0]['Diastole'].toString();
        _neuerPulsdruck = (neueDaten[0]['Systole'] - neueDaten[0]['Diastole']).toString();
        _neuerPuls = neueDaten[0]['Puls'].toString();
        if (neueDaten[0]['Gewicht'].toString().isNotEmpty && neueDaten[0]['Gewicht'] != null) {
          _neuesGewicht = neueDaten[0]['Gewicht'].toString();
        } else {
          _neuesGewicht = "";
        }
        _neueBemerkung = '';
      } else {
        _neuerZeitpunkt = globals.zeitpunktNeuerEintrag;
        _neueSystole = '120';
        _neueDiastole = '80';
        _neuerPulsdruck = '40';
        _neuerPuls = '60';
        _neuesGewicht = '77.7';
        _neueBemerkung = '';
      }
      _hasChanged = true;
    } else {
      _datensatz = await dbHelper.getDataItem(globals.aktID);
      _neuerZeitpunkt = _datensatz[0]['Zeitpunkt'].toString();
      _neueSystole = _datensatz[0]['Systole'].toString();
      _neueDiastole = _datensatz[0]['Diastole'].toString();
      _neuerPulsdruck = (_datensatz[0]['Systole'] - _datensatz[0]['Diastole']).toString();
      _neuerPuls = _datensatz[0]['Puls'].toString();
      if (_datensatz[0]['Gewicht'].toString().isNotEmpty && _datensatz[0]['Gewicht'] != null) {
        _neuesGewicht = _datensatz[0]['Gewicht'].toString();
      } else {
        _neuesGewicht = "";
      }
      _neueBemerkung = _datensatz[0]['Bemerkung'];
    }
    ctrSystole.value = TextEditingValue(text: _neueSystole);
    ctrDiastole.value = TextEditingValue(text: _neueDiastole);
    ctrPuls.value = TextEditingValue(text: _neuerPuls);
    ctrGewicht.value = TextEditingValue(text: _neuesGewicht);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'de_DE';
    _ladeDaten();
  }

  void incrSystole() {
    int? neuerWert = int.tryParse(_neueSystole);
    if (neuerWert == null) {
      neuerWert = 1;
    } else {
      neuerWert++;
    }
    int? Diastole = int.tryParse(_neueDiastole);
    _neuerPulsdruck = (neuerWert - Diastole!).toString();
    setState(() {
      ctrSystole.value = TextEditingValue(text: neuerWert.toString());
      _neueSystole = neuerWert.toString();
      _hasChanged = true;
      if (kDebugMode) {
        print(_neueSystole);
      }
    });
  }

  void decrSystole() {
    int? neuerWert = int.tryParse(_neueSystole);
    if (neuerWert == null) {
      neuerWert = 1;
    } else {
      if (neuerWert > 0) neuerWert--;
    }
    int? Diastole = int.tryParse(_neueDiastole);
    _neuerPulsdruck = (neuerWert - Diastole!).toString();
    setState(() {
      ctrSystole.value = TextEditingValue(text: neuerWert.toString());
      _neueSystole = neuerWert.toString();
      _hasChanged = true;
      if (kDebugMode) {
        print(_neueSystole);
      }
    });
  }

  void incrDiastole() {
    int? neuerWert = int.tryParse(_neueDiastole);
    if (neuerWert == null) {
      neuerWert = 1;
    } else {
      neuerWert++;
    }
    int? Systole = int.tryParse(_neueSystole);
    _neuerPulsdruck = (Systole! - neuerWert).toString();
    setState(() {
      ctrDiastole.value = TextEditingValue(text: neuerWert.toString());
      _neueDiastole = neuerWert.toString();
      _hasChanged = true;
      if (kDebugMode) {
        print(_neueDiastole);
      }
    });
  }

  void decrDiastole() {
    int? neuerWert = int.tryParse(_neueDiastole);
    if (neuerWert == null) {
      neuerWert = 1;
    } else {
      if (neuerWert > 0) neuerWert--;
    }
    int? Systole = int.tryParse(_neueSystole);
    _neuerPulsdruck = (Systole! - neuerWert).toString();
    setState(() {
      ctrDiastole.value = TextEditingValue(text: neuerWert.toString());
      _neueDiastole = neuerWert.toString();
      _hasChanged = true;
      if (kDebugMode) {
        print(_neueDiastole);
      }
    });
  }

  void incrPuls() {
    int? neuerWert = int.tryParse(_neuerPuls);
    if (neuerWert == null) {
      neuerWert = 1;
    } else {
      neuerWert++;
    }
    setState(() {
      ctrPuls.value = TextEditingValue(text: neuerWert.toString());
      _neuerPuls = neuerWert.toString();
      _hasChanged = true;
      if (kDebugMode) {
        print(_neuerPuls);
      }
    });
  }

  void decrPuls() {
    int? neuerWert = int.tryParse(_neuerPuls);
    if (neuerWert == null) {
      neuerWert = 1;
    } else {
      if (neuerWert > 0) neuerWert--;
    }
    setState(() {
      ctrPuls.value = TextEditingValue(text: neuerWert.toString());
      _neuerPuls = neuerWert.toString();
      _hasChanged = true;
      if (kDebugMode) {
        print(_neuerPuls);
      }
    });
  }

  void incrGewicht() {
    double? neuerWert = double.tryParse(_neuesGewicht);
    String zwi = neuerWert!.toStringAsFixed(1);
    neuerWert = double.tryParse(zwi);
    if (neuerWert == null) {
      neuerWert = 1;
    } else {
      neuerWert += 0.1;
    }
    setState(() {
      ctrGewicht.value = TextEditingValue(text: neuerWert!.toStringAsFixed(1));
      _neuesGewicht = neuerWert.toString();
      _hasChanged = true;
      if (kDebugMode) {
        print(_neuesGewicht);
      }
    });
  }

  void decrGewicht() {
    double? neuerWert = double.tryParse(_neuesGewicht);
    String zwi = neuerWert!.toStringAsFixed(1);
    neuerWert = double.tryParse(zwi);
    if (neuerWert == null) {
      neuerWert = 1;
    } else {
      if (neuerWert > 0) neuerWert -= 0.1;
    }
    setState(() {
      ctrGewicht.value = TextEditingValue(text: neuerWert!.toStringAsFixed(1));
      _neuesGewicht = neuerWert.toString();
      _hasChanged = true;
      if (kDebugMode) {
        print(_neuesGewicht);
      }
    });
  }

  String? isNumeric(String val) {
    try {
      var regex = RegExp(r'\d+');
      if (val.contains(regex) == false) {
        return "nur Zahlen!";
      }
      // if ( val.toLowerCase().contains("abcdefghijklmnopqrstuvwxyz<>!'§\$\%&/()=?ß\\{[]}") == true ) {
      //   return "bitte nur Ziffern!";
      // }
      if (double.tryParse(val)! <= 0) {
        return 'nur größer als 0!';
      }
      return null;
    } catch (_, e) {
      return "falsche Eingabe $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = Screen.isLandscape(context);
    // bool isLargePhone = Screen.diagonal(context) > 720;
    // bool isNarrow = Screen.widthInches(context) < 3.5;
    bool isTablet = Screen.diagonalInches(context) >= 8.5; // war 7s
    var myProvider = Provider.of<myUpdateProvider>(context, listen: false);
    if (isTablet) {
      _padding_top = 25.0;
      _padding_left = 25.0;
      _padding_right = 25.0;
      _padding_bottom = 25.0;
      _flexval = 6;
    } else {
      _padding_top = 15.0;
      _padding_left = 15.0;
      _padding_right = 15.0;
      _padding_bottom = 15.0;
      _flexval = 3;
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(aktID > -1 ? " Details" : "Details (NEU)"),
          actions: [
            Visibility(
              visible: _hasChanged,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    // Wenn alle Validatoren der Felder des Formulars gültig sind.
                    if (_formKey.currentState!.validate()) {
                      await _aendereDatensatz();
                      myProvider.updateAll();
                      _hasChanged = false;
                    } else {
                      if (kDebugMode) {
                        print("Formular ist nicht gültig");
                      }
                    }
                  },
                  child: Row(
                    children: [
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
            : SingleChildScrollView(
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(_padding_left, _padding_top, _padding_right, _padding_bottom),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          DateTimePicker(
                            style: const TextStyle(color: Colors.black, fontSize: 25.0, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            type: DateTimePickerType.dateTimeSeparate,
                            dateMask: 'dd.MM.yyyy',
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            // calendarTitle: 'Datum des Eintrags',
                            dateLabelText: 'Datum',
                            timeLabelText: 'Uhrzeit',
                            use24HourFormat: true,
                            locale: const Locale('de', 'DE'),
                            timeFieldWidth: (MediaQuery.of(context).size.width - _padding_left - _padding_right) / 2.0,
                            icon: const Icon(Icons.event),
                            initialValue: _neuerZeitpunkt,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.black12,
                              contentPadding: EdgeInsets.fromLTRB(0.0, 20, 0.0, 20),
                              labelText: 'Zeitpunkt',
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _hasChanged = true;
                                _neuerZeitpunkt = DateTime.parse(val).toString();
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Systole
                          // -------

                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 1,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: globals.BgColorNeutral,
                                      elevation: 2.0,
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold),
                                      fixedSize: Size(35, 70),
                                    ),
                                    onPressed: () => decrSystole(),
                                    child: const Text('-')),
                              ),
                              // SizedBox(width: 5),
                              Flexible(
                                flex: _flexval,
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.black, fontSize: 25.0, fontWeight: FontWeight.bold),
                                  controller: ctrSystole,
                                  // initialValue: _neueSystole,
                                  keyboardType: TextInputType.number,
                                  autocorrect: true,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 20, 0.0, 20),
                                    constraints: BoxConstraints(
                                        // maxWidth: 180,
                                        ),
                                    // label: Text('Systole (mmHg)', textScaleFactor: 1.0,),
                                    labelText: 'Systole (mmHg)',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "Eingabe ist erforderlich";
                                    } else {
                                      return isNumeric(val);
                                    }
                                  },
                                  onSaved: (val) => setState(() => _neueSystole = val!),
                                ),
                              ),
                              // SizedBox(width: 10),
                              Flexible(
                                flex: 1,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: globals.BgColorNeutral,
                                      elevation: 2.0,
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold),
                                      fixedSize: Size(35, 70),
                                    ),
                                    onPressed: () => incrSystole(),
                                    child: const Text('+')),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 20),

                          // Pulsdruck
                          // ---------
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 80.0,
                                color: int.tryParse(_neuerPulsdruck)! < 40
                                    ? Colors.yellow[100]
                                    : int.tryParse(_neuerPulsdruck)! <= 65.0
                                    ? Colors.green[200]
                                    : int.tryParse(_neuerPulsdruck)! <= 75.0
                                    ? Colors.red[100]
                                    : int.tryParse(_neuerPulsdruck)! <= 90
                                    ? Colors.red[300]
                                    : Colors.red,
                                child: Text(
                                  _neuerPulsdruck,
                                  style: const TextStyle(fontSize: 20.0, ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                width: 75.0,
                                child: Text(' '),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 10),

                          // Diastole
                          // --------

                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: globals.BgColorNeutral,
                                      elevation: 2.0,
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold),
                                      fixedSize: Size(35, 70),
                                    ),
                                    onPressed: () => decrDiastole(),
                                    child: const Text('-')),
                              ),
                              Flexible(
                                flex: _flexval,
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.black, fontSize: 25.0, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  controller: ctrDiastole,
                                  // initialValue: _neueDiastole,
                                  keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                                  autocorrect: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    // fillColor: globals.Farbe1Systole(ctrDiastole.value as int),
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 20, 0.0, 20),
                                    constraints: BoxConstraints(
                                        // maxWidth: 180,
                                        ),
                                    // label: Text('Diastole (mmHg)', textScaleFactor: 1.0,),
                                    labelText: 'Diastole (mmHg)',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "Eingabe ist erforderlich";
                                    } else {
                                      return isNumeric(val);
                                    }
                                  },
                                  onSaved: (val) => setState(() => _neueDiastole = val!),
                                ),
                              ),
                              Flexible(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: globals.BgColorNeutral,
                                      elevation: 2.0,
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold),
                                      fixedSize: Size(35, 70),
                                    ),
                                    onPressed: () => incrDiastole(),
                                    child: const Text('+')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Puls
                          // ----

                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: globals.BgColorNeutral,
                                      elevation: 2.0,
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold),
                                      fixedSize: Size(35, 70),
                                    ),
                                    onPressed: () => decrPuls(),
                                    child: const Text('-')),
                              ),
                              Flexible(
                                flex: _flexval,
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.black, fontSize: 25.0, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  controller: ctrPuls,
                                  // initialValue: _neuerPuls.toString(),
                                  keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                                  autocorrect: true,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 20, 0.0, 20),
                                    constraints: BoxConstraints(
                                        // maxWidth: 180,
                                        ),
                                    // label: Text('Puls (bpm)', textScaleFactor: 1.0,),
                                    labelText: 'Puls (bpm)',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "Eingabe ist erforderlich";
                                    } else {
                                      return isNumeric(val);
                                    }
                                  },
                                  onSaved: (val) => setState(() => _neuerPuls = val!),
                                ),
                              ),
                              Flexible(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: globals.BgColorNeutral,
                                      elevation: 2.0,
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold),
                                      fixedSize: Size(35, 70),
                                    ),
                                    onPressed: () => incrPuls(),
                                    child: const Text('+')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Gewicht
                          // -------

                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: globals.BgColorNeutral,
                                      elevation: 2.0,
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold),
                                      fixedSize: Size(35, 70),
                                    ),
                                    onPressed: () => decrGewicht(),
                                    child: const Text('-')),
                              ),
                              Flexible(
                                flex: _flexval,
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.black, fontSize: 25.0, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  controller: ctrGewicht,
                                  // initialValue: _neuesGewicht.toString(),
                                  keyboardType: TextInputType.number,
                                  autocorrect: true,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black12,
                                    contentPadding: EdgeInsets.fromLTRB(0.0, 20, 0.0, 20),
                                    constraints: BoxConstraints(
                                        // maxWidth: 180,
                                        ),
                                    //label: Text('Gewicht (kg)', textScaleFactor: 1.0,),
                                    labelText: 'Gewicht (kg)',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return null;
                                    } else {
                                      return isNumeric(val);
                                    }
                                  },
                                  onSaved: (val) {
                                    setState(() {
                                      _hasChanged = true;
                                      _neuesGewicht = val!;
                                    });
                                  },
                                ),
                              ),
                              Flexible(
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: globals.BgColorNeutral,
                                      elevation: 2.0,
                                      textStyle: const TextStyle(color: Colors.black, fontSize: 40.0, fontWeight: FontWeight.bold),
                                      fixedSize: Size(35, 70),
                                    ),
                                    onPressed: () => incrGewicht(),
                                    child: const Text('+')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Colors.black, fontSize: 25.0, fontWeight: FontWeight.bold),
                            initialValue: _neueBemerkung,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            //expands: true,
                            autocorrect: true,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.black12,
                              labelText: 'Bemerkung',
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (val) {
                              _hasChanged = true;
                              setState(() {
                                if ( val.toString().isNotEmpty ) {
                                  _neueBemerkung = val;
                                } else {
                                  _neueBemerkung = '';
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
