library stats;

import '../../my-globals.dart' as globals;
import 'package:sysdiapulsgew/services/dbhelper.dart';

// Variablen für Seite "alle"
// --------------------------
var strSysVorm = [];
var strSysNachm = [];
var strSysAbends = [];
var strDiaVorm = [];
var strDiaNachm = [];
var strDiaAbends = [];
var strPulsVorm = [];
var strPulsNachm = [];
var strPulsAbends = [];
var intSysVorm = [];
var intSysNachm = [];
var intSysAbends = [];
var intDiaVorm = [];
var intDiaNachm = [];
var intDiaAbends = [];
var intPulsVorm = [];
var intPulsNachm = [];
var intPulsAbends = [];
var Farbe1SysVorm = [];
var Farbe1SysNachm = [];
var Farbe1SysAbends = [];
var Farbe1DiaVorm = [];
var Farbe1DiaNachm = [];
var Farbe1DiaAbends = [];
var Farbe1PulsVorm = [];
var Farbe1PulsNachm = [];
var Farbe1PulsAbends = [];
var Farbe2SysVorm = [];
var Farbe2SysNachm = [];
var Farbe2SysAbends = [];
var Farbe2DiaVorm = [];
var Farbe2DiaNachm = [];
var Farbe2DiaAbends = [];
var Farbe2PulsVorm = [];
var Farbe2PulsNachm = [];
var Farbe2PulsAbends = [];

Future<int> _teste(String s) async {
  int? retVal;
  if ( s.contains("keine Daten") || s.contains("Fehler") ) {
    retVal = -1;
  } else if ( globals.isNumeric(s) ) {
    retVal = int.tryParse(double.tryParse(s)!.round().toString());
  }
  retVal ??= -1;
  return retVal;
}

const IndexAlle = 0;
const Index1W = 1;
const Index1M = 2;
Future<void> ladeDaten() async {
  await _ladeDatenAlle(IndexAlle, "alle");
  await _ladeDatenAlle(Index1W, "-7");
  await _ladeDatenAlle(Index1M, "-31");
}

Future<void> _ladeDatenAlle(int Index, String Zeitraum) async {
  strSysVorm.add( { Zeitraum : await dbHelper.getAVGVonBis("Systole", "06:00", "12:00", Zeitraum) } );
  strSysNachm.add( { Zeitraum : await dbHelper.getAVGVonBis("Systole", "12:00", "18:00", Zeitraum) } );
  strSysAbends.add( { Zeitraum : await dbHelper.getAVGVonBis("Systole", "18:00", "23:59", Zeitraum) } );

  strDiaVorm.add( { Zeitraum : await dbHelper.getAVGVonBis("Diastole", "06:00", "12:00", Zeitraum) } );
  strDiaNachm.add( { Zeitraum : await dbHelper.getAVGVonBis("Diastole", "12:00", "18:00", Zeitraum) } );
  strDiaAbends.add( { Zeitraum : await dbHelper.getAVGVonBis("Diastole", "18:00", "23:59", Zeitraum) } );

  strPulsVorm.add( { Zeitraum : await dbHelper.getAVGVonBis("Puls", "06:00", "12:00", Zeitraum) } );
  strPulsNachm.add( { Zeitraum : await dbHelper.getAVGVonBis("Puls", "12:00", "18:00", Zeitraum) } );
  strPulsAbends.add( { Zeitraum : await dbHelper.getAVGVonBis("Puls", "18:00", "23:59", Zeitraum) } );

  intSysVorm.add( { Zeitraum : await _teste(strSysVorm[Index][Zeitraum]) } );
  intSysNachm.add( { Zeitraum : await _teste(strSysNachm[Index][Zeitraum]) } );
  intSysAbends.add( { Zeitraum : await _teste(strSysAbends[Index][Zeitraum]) } );

  intDiaVorm.add( { Zeitraum : await _teste(strDiaVorm[Index][Zeitraum]) } );
  intDiaNachm.add( { Zeitraum : await _teste(strDiaNachm[Index][Zeitraum]) } );
  intDiaAbends.add( { Zeitraum : await _teste(strDiaAbends[Index][Zeitraum]) } );

  intPulsVorm.add( { Zeitraum : await _teste(strPulsVorm[Index][Zeitraum]) } );
  intPulsNachm.add( { Zeitraum : await _teste(strPulsNachm[Index][Zeitraum]) } );
  intPulsAbends.add( { Zeitraum : await _teste(strPulsAbends[Index][Zeitraum]) } );

  Farbe1SysVorm.add( { Zeitraum : globals.Farbe1Systole(intSysVorm[Index][Zeitraum]) } );
  Farbe1SysNachm.add( { Zeitraum : globals.Farbe1Systole(intSysNachm[Index][Zeitraum]) } );
  Farbe1SysAbends.add( { Zeitraum : globals.Farbe1Systole(intSysAbends[Index][Zeitraum]) } );

  Farbe1DiaVorm.add( { Zeitraum : globals.Farbe1Diastole(intDiaVorm[Index][Zeitraum]) } );
  Farbe1DiaNachm.add( { Zeitraum : globals.Farbe1Diastole(intDiaNachm[Index][Zeitraum]) } );
  Farbe1DiaAbends.add( { Zeitraum : globals.Farbe1Diastole(intDiaAbends[Index][Zeitraum]) } );

  Farbe1PulsVorm.add( { Zeitraum : globals.Farbe1Puls(intPulsVorm[Index][Zeitraum]) } );
  Farbe1PulsNachm.add( { Zeitraum : globals.Farbe1Puls(intPulsNachm[Index][Zeitraum]) } );
  Farbe1PulsAbends.add( { Zeitraum : globals.Farbe1Puls(intPulsAbends[Index][Zeitraum]) } );

  Farbe2SysVorm.add( { Zeitraum : globals.Farbe2Systole(intSysVorm[Index][Zeitraum]) } );
  Farbe2SysNachm.add( { Zeitraum : globals.Farbe2Systole(intSysNachm[Index][Zeitraum]) } );
  Farbe2SysAbends.add( { Zeitraum : globals.Farbe2Systole(intSysAbends[Index][Zeitraum]) } );

  Farbe2DiaVorm.add( { Zeitraum : globals.Farbe2Diastole(intDiaVorm[Index][Zeitraum]) } );
  Farbe2DiaNachm.add( { Zeitraum : globals.Farbe2Diastole(intDiaNachm[Index][Zeitraum]) } );
  Farbe2DiaAbends.add( { Zeitraum : globals.Farbe2Diastole(intDiaAbends[Index][Zeitraum]) } );

  Farbe2PulsVorm.add( { Zeitraum : globals.Farbe2Puls(intPulsVorm[Index][Zeitraum]) } );
  Farbe2PulsNachm.add( { Zeitraum : globals.Farbe2Puls(intPulsNachm[Index][Zeitraum]) } );
  Farbe2PulsAbends.add( { Zeitraum : globals.Farbe2Puls(intPulsAbends[Index][Zeitraum]) } );
}
