import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../../my-globals.dart' as globals;
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>>_datensatz = [];
  int aktID = -1;

  TextEditingController ctrSystole = TextEditingController();
  TextEditingController ctrDiastole = TextEditingController();
  TextEditingController ctrPuls = TextEditingController();
  TextEditingController ctrGewicht = TextEditingController();
  String _neuerZeitpunkt = '';
  String _neueSystole = '';
  String _neueDiastole = '';
  String _neuerPuls = '';
  String _neuesGewicht = '';
  String _neueBemerkung = '';

  void _aendereDatensatz() async {
    _formKey.currentState?.save();
    int id = globals.aktID;
    int? Systole = int.tryParse(_neueSystole);
    int? Diastole = int.tryParse(_neueDiastole);
    int? Puls = int.tryParse(_neuerPuls);
    String Zeitpunkt = _neuerZeitpunkt;
    double? Gewicht = double.tryParse(_neuesGewicht);
    String Bemerkung = _neueBemerkung;
    int result = -1;

    if ( globals.aktID == -1 ) {
      result = await dbHelper.createDataItem(Zeitpunkt, Systole!, Diastole!, Puls, Gewicht, Bemerkung);
    } else {
      result = await dbHelper.updateDataItem(id, Systole!, Diastole!, Puls!, Zeitpunkt, Gewicht, Bemerkung);
    }
    if ( result != 0 ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Änderungen gespeichert.'),
          backgroundColor: Colors.green
        )
      );
      // kehrt zur Liste der Einträge zurück
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Fehler beim Speichern!'),
              backgroundColor: Colors.red
          )
      );
    }
  }

  void _ladeDaten() async {
    aktID = globals.aktID;
    if ( globals.aktID == -1 ) {
      final Anz = await dbHelper.getEntryCount();
      int iAnz = 0;
      if ( Anz.isNotEmpty ) {
        iAnz = int.tryParse(Anz[0]['Cnt'].toString())!;
      } else {
        iAnz = 0;
      }
      if ( iAnz > 0 ) {
        final _neueDaten = await dbHelper.getLastEntry();
        print(_neueDaten);
        _neuerZeitpunkt = DateTime.now().toString();
        _neueSystole = _neueDaten[0]['Systole'].toString();
        _neueDiastole = _neueDaten[0]['Diastole'].toString();
        _neuerPuls = _neueDaten[0]['Puls'].toString();
        if ( _neueDaten[0]['Gewicht'].toString().isNotEmpty && _neueDaten[0]['Gewicht'] != null ) {
          _neuesGewicht = _neueDaten[0]['Gewicht'].toString();
        } else {
          _neuesGewicht = "";
        }
        _neueBemerkung = '';
      } else {
        _neuerZeitpunkt = DateTime.now().toString();
        _neueSystole = '120';
        _neueDiastole = '80';
        _neuerPuls = '60';
        _neuesGewicht = '77.7';
        _neueBemerkung = '';
      }
    } else {
      _datensatz = await dbHelper.getDataItem(globals.aktID);
      _neuerZeitpunkt = _datensatz[0]['Zeitpunkt'].toString();
      _neueSystole = _datensatz[0]['Systole'].toString();
      _neueDiastole = _datensatz[0]['Diastole'].toString();
      _neuerPuls = _datensatz[0]['Puls'].toString();
      if ( _datensatz[0]['Gewicht'].toString().isNotEmpty && _datensatz[0]['Gewicht'] != null ) {
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
    if ( mounted ) setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'de_DE';
    _ladeDaten();
  }

  void incrSystole() {
    int? neuerWert = int.tryParse(_neueSystole);
    if ( neuerWert == null ) {
      neuerWert = 1;
    } else {
      neuerWert++;
    }
    setState(() {
      ctrSystole.value = TextEditingValue(text: neuerWert.toString());
      _neueSystole = neuerWert.toString();
      print(_neueSystole);
    });
  }
  void decrSystole() {
    int? neuerWert = int.tryParse(_neueSystole);
    if ( neuerWert == null ) {
      neuerWert = 1;
    } else {
      if ( neuerWert > 0 ) neuerWert--;
    }
    setState(() {
      ctrSystole.value = TextEditingValue(text: neuerWert.toString());
      _neueSystole = neuerWert.toString();
      print(_neueSystole);
    });
  }

  void incrDiastole() {
    int? neuerWert = int.tryParse(_neueDiastole);
    if ( neuerWert == null ) {
      neuerWert = 1;
    } else {
      neuerWert++;
    }
    setState(() {
      ctrDiastole.value = TextEditingValue(text: neuerWert.toString());
      _neueDiastole = neuerWert.toString();
      print(_neueDiastole);
    });
  }
  void decrDiastole() {
    int? neuerWert = int.tryParse(_neueDiastole);
    if ( neuerWert == null ) {
      neuerWert = 1;
    } else {
      if ( neuerWert > 0 ) neuerWert--;
    }
    setState(() {
      ctrDiastole.value = TextEditingValue(text: neuerWert.toString());
      _neueDiastole = neuerWert.toString();
      print(_neueDiastole);
    });
  }

  void incrPuls() {
    int? neuerWert = int.tryParse(_neuerPuls);
    if ( neuerWert == null ) {
      neuerWert = 1;
    } else {
      neuerWert++;
    }
    setState(() {
      ctrPuls.value = TextEditingValue(text: neuerWert.toString());
      _neuerPuls = neuerWert.toString();
      print(_neuerPuls);
    });
  }
  void decrPuls() {
    int? neuerWert = int.tryParse(_neuerPuls);
    if ( neuerWert == null ) {
      neuerWert = 1;
    } else {
      if ( neuerWert > 0 ) neuerWert--;
    }
    setState(() {
      ctrPuls.value = TextEditingValue(text: neuerWert.toString());
      _neuerPuls = neuerWert.toString();
      print(_neuerPuls);
    });
  }

  void incrGewicht() {
    double? neuerWert = double.tryParse(_neuesGewicht);
    String zwi = neuerWert!.toStringAsFixed(1);
    neuerWert = double.tryParse(zwi);
    if ( neuerWert == null ) {
      neuerWert = 1;
    } else {
      neuerWert += 0.1;
    }
    setState(() {
      ctrGewicht.value = TextEditingValue(text: neuerWert!.toStringAsFixed(1));
      _neuesGewicht = neuerWert.toString();
      print(_neuesGewicht);
    });
  }
  void decrGewicht() {
    double? neuerWert = double.tryParse(_neuesGewicht);
    String zwi = neuerWert!.toStringAsFixed(1);
    neuerWert = double.tryParse(zwi);
    if ( neuerWert == null ) {
      neuerWert = 1;
    } else {
      if ( neuerWert > 0 ) neuerWert -= 0.1;
    }
    setState(() {
      ctrGewicht.value = TextEditingValue(text: neuerWert!.toStringAsFixed(1));
      _neuesGewicht = neuerWert.toString();
      print(_neuesGewicht);
    });
  }

  String? isNumeric(String val) {
    try {
      print("isNumeric() - $val");
      var regex = RegExp(r'\d+');
      if ( val.contains(regex) == false ) {
        return "nur Zahlen!";
      }
      // if ( val.toLowerCase().contains("abcdefghijklmnopqrstuvwxyz<>!'§\$\%&/()=?ß\\{[]}") == true ) {
      //   return "bitte nur Ziffern!";
      // }
      if ( double.tryParse(val)! <= 0 ) {
        return 'nur größer als 0!';
      }
    } catch (_, e) {
      return "falsche Eingabe $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(aktID > -1 ? " Details (ID: $aktID)" : "Details (NEU)"),
        ),
        body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
          child: Center(
            child: Container(
              width: 370,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(50, 25, 50, 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      DateTimePicker(
                        textAlign: TextAlign.center,
                        type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'dd.MM.yyyy',
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        dateLabelText: 'Datum',
                        timeLabelText: 'Uhrzeit',
                        use24HourFormat: true,
                        locale: Locale('de', 'DE'),
                        icon: Icon(Icons.event),
                        initialValue: _neuerZeitpunkt,
                        decoration: InputDecoration(
                          labelText: 'Zeitpunkt',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (val) => setState(() => val != null ? _neuerZeitpunkt = DateTime.parse(val).toString() : ''),
                      ),
                      SizedBox(height: 10),

                      // Systole
                      // -------

                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xF3F3F3),
                              textStyle: TextStyle(color: Colors.black),
                              fixedSize: Size(55, 55),
                            ),
                            onPressed: () => decrSystole(),
                            child: Text('-')
                          ),
                          // SizedBox(width: 5),
                          TextFormField(
                            controller: ctrSystole,
                            // initialValue: _neueSystole,
                            keyboardType: TextInputType.number,
                            autocorrect: true,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              constraints: BoxConstraints(
                                maxWidth: 120,
                              ),
                              labelText: 'Systole',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if ( val!.isEmpty ) {
                                return "Eingabe ist erforderlich";
                              } else {
                                return isNumeric(val);
                              }
                            },
                            onSaved: (val) => setState(() => _neueSystole = val!),
                          ),
                          // SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xF3F3F3),
                              textStyle: TextStyle(color: Colors.black),
                              fixedSize: Size(55, 55),
                            ),
                            onPressed: () => incrSystole(),
                            child: Text('+')
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Diastole
                      // --------

                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xF3F3F3),
                                textStyle: TextStyle(color: Colors.black),
                                fixedSize: Size(55, 55),
                              ),
                              onPressed: () => decrDiastole(),
                              child: Text('-')
                          ),
                          TextFormField(
                            textAlign: TextAlign.center,
                            controller: ctrDiastole,
                            // initialValue: _neueDiastole,
                            keyboardType: TextInputType.numberWithOptions(
                                signed: false,
                                decimal: false
                            ),
                            autocorrect: true,
                            decoration: InputDecoration(
                              constraints: BoxConstraints(
                                maxWidth: 120,
                              ),
                              labelText: 'Diastole',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if ( val!.isEmpty ) {
                                return "Eingabe ist erforderlich";
                              } else {
                                return isNumeric(val);
                              }
                            },
                            onSaved: (val) => setState(() => _neueDiastole = val!),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xF3F3F3),
                                textStyle: TextStyle(color: Colors.black),
                                fixedSize: Size(55, 55),
                              ),
                              onPressed: () => incrDiastole(),
                              child: Text('+')
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Puls
                      // ----

                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xF3F3F3),
                                textStyle: TextStyle(color: Colors.black),
                                fixedSize: Size(55, 55),
                              ),
                              onPressed: () => decrPuls(),
                              child: Text('-')
                          ),
                          TextFormField(
                            textAlign: TextAlign.center,
                            controller: ctrPuls,
                            // initialValue: _neuerPuls.toString(),
                            keyboardType: TextInputType.numberWithOptions(
                                signed: false,
                                decimal: false
                            ),
                            autocorrect: true,
                            decoration: InputDecoration(
                              constraints: BoxConstraints(
                                maxWidth: 120,
                              ),
                              labelText: 'Puls',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if ( val!.isEmpty ) {
                                return "Eingabe ist erforderlich";
                              } else {
                                return isNumeric(val);
                              }
                            },
                            onSaved: (val) => setState(() => _neuerPuls = val!),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xF3F3F3),
                                textStyle: TextStyle(color: Colors.black),
                                fixedSize: Size(55, 55),
                              ),
                              onPressed: () => incrPuls(),
                              child: Text('+')
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Gewicht
                      // -------

                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xF3F3F3),
                                textStyle: TextStyle(color: Colors.black),
                                fixedSize: Size(55, 55),
                              ),
                              onPressed: () => decrGewicht(),
                              child: Text('-')
                          ),
                          TextFormField(
                            textAlign: TextAlign.center,
                            controller: ctrGewicht,
                            // initialValue: _neuesGewicht.toString(),
                            keyboardType: TextInputType.number,
                            autocorrect: true,
                            decoration: InputDecoration(
                              constraints: BoxConstraints(
                                maxWidth: 120,
                              ),
                              labelText: 'Gewicht',
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if ( val!.isEmpty ) {
                                return null;
                              } else {
                                return isNumeric(val);
                              }
                            },
                            onSaved: (val) => setState(() => _neuesGewicht = val!),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xF3F3F3),
                                textStyle: TextStyle(color: Colors.black),
                                fixedSize: Size(55, 55),
                              ),
                              onPressed: () => incrGewicht(),
                              child: Text('+')
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        initialValue: _neueBemerkung,
                        keyboardType: TextInputType.text,
                        //expands: true,
                        autocorrect: true,
                        decoration: InputDecoration(
                          labelText: 'Bemerkung',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (val) => setState(() => _neueBemerkung = val ?? ''),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                              textStyle: TextStyle(color: Colors.white)),
                            onPressed: () {
                              // reset() setzt alle Felder wieder auf den Initialwert zurück.
                              _formKey.currentState!.reset();
                              // kehrt zur Liste der Einträge zurück
                              Navigator.pop(context);
                            },
                            child: Text('Abbrechen')
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Wenn alle Validatoren der Felder des Formulars gültig sind.
                              if (_formKey.currentState!.validate()) {
                                _aendereDatensatz();
                              } else {
                                print("Formular ist nicht gültig");
                              }
                            },
                            child: Text('OK')
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
