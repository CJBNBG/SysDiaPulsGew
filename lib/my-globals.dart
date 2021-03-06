library globals;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

PackageInfo gPackageInfo = PackageInfo(appName: "", packageName: "", version: "", buildNumber: "");
int screenwidth = 0;
int screenheight = 0;
String lokalDBDir = "/sdcard/";
String lokalDBPfad = lokalDBDir + "SysDiaPulsGew/";
String lokalDBNameOhnePfad = "SysDiaPulsGew.db";
String lokalDBNameMitPfad = lokalDBPfad + lokalDBNameOhnePfad;
bool updAVG_needed = false;

int aktID = -1;
const EntryWidthSysDia = 55.0;
const CardWidth = 310.0;

const scaleFactorTablet = 1.65;
const scaleFactorPhone = 1.1;
const BemlenTablet = 50;
const BemlenPhone = 25;
const EntryHeight = 92.0;
late DateTime calendarStart;

// Farbdefinitionen
Color BgColorNeutral = Colors.white;        // wird in der build-Methode der Klasse _MyAppState gesetzt

Color SysDia_optimal = Color.fromRGBO(0, 114, 67, 1);          // 007243
Color SysDia_normal = Color.fromRGBO(0, 255, 0, 1);            // 00ff00
Color SysDia_hochnormal = Color.fromRGBO(245, 255, 0, 1);      // f5ff00
Color SysDia_Stufe_1 = Color.fromRGBO(255, 186, 83, 1);
Color SysDia_Stufe_2 = Color.fromRGBO(255, 138, 138, 1);
Color SysDia_Stufe_3 = Colors.red;

Color SysDia_optimal_blass = Color.fromRGBO(248, 255, 247, 1); // #f8fff7
Color SysDia_normal_blass = Color.fromRGBO(248, 255, 247, 1);  // f8fff7
Color SysDia_hochnormal_blass = Color.fromRGBO(250, 250, 245, 1);
Color SysDia_Stufe_1_blass = Color.fromRGBO(248, 247, 243, 1);
Color SysDia_Stufe_2_blass = Color.fromRGBO(250, 243, 243, 1);
Color SysDia_Stufe_3_blass = Color.fromRGBO(255, 249, 249, 1);

Color Puls_langsam = Color.fromRGBO(0, 255, 255, 1);            // aqua
Color Puls_normal = Color.fromRGBO(0, 255, 0, 1);               // 00ff00
Color Puls_schnell = Colors.red;
Color Puls_fehlt = Colors.white;

Color Puls_langsam_blass = Color.fromRGBO(246, 253, 253, 1);
Color Puls_normal_blass = Color.fromRGBO(248, 255, 247, 1);     // f8fff7
Color Puls_schnell_blass = Color.fromRGBO(253, 246, 246, 1);

Color Gewicht_normal = Color.fromRGBO(0, 255, 0, 1);            // 00ff00
Color Gewicht_normal_blass = Color.fromRGBO(248, 255, 247, 1);  // f8fff7
Color Gewicht_fehlt = Colors.white;

// Farbfunktionen
Color Farbe1Systole(int Wert) {
  if ( Wert == -1 ) {
    return BgColorNeutral;
  } else if ( Wert<120 ) {                             // optimal
    return SysDia_optimal;
  } else if ( Wert >= 120 && Wert < 130 ) {     // normal
    return SysDia_normal;
  } else if ( Wert >= 130 && Wert < 140 ) {     // hochnormal
    return SysDia_hochnormal;
  } else if ( Wert >= 140 && Wert < 160 ) {     // Stufe 1
    return SysDia_Stufe_1;
  } else if ( Wert >= 160 && Wert < 180 ) {     // Stufe 2
    return SysDia_Stufe_2;
  } else {                                      // Stufe 3
    return SysDia_Stufe_3;
  }
}
Color? Farbe2Systole(int Wert) {
  if ( Wert == -1 ) {
    return BgColorNeutral;
  } else if ( Wert<120 ) {
    return SysDia_optimal_blass;
  } else if ( Wert >= 120 && Wert < 130 ) {
    return SysDia_normal_blass;
  } else if ( Wert >= 130 && Wert < 140 ) {
    return SysDia_hochnormal_blass;
  } else if ( Wert >= 140 && Wert < 160 ) {
    return SysDia_Stufe_1_blass;
  } else if ( Wert >= 160 && Wert < 180 ) {
    return SysDia_Stufe_2_blass;
  } else {
    return SysDia_Stufe_3_blass;
  }
}

Color Farbe1Diastole(int Wert) {
  if ( Wert == -1 ) {
    return BgColorNeutral;
  } else if ( Wert<80 ) {
    return SysDia_optimal;
  } else if ( Wert >= 80 && Wert < 85 ) {
    return SysDia_normal;
  } else if ( Wert >= 85 && Wert < 90 ) {
    return SysDia_hochnormal;
  } else if ( Wert >= 90 && Wert < 100 ) {
    return SysDia_Stufe_1;
  } else if ( Wert >= 100 && Wert < 110 ) {
    return SysDia_Stufe_2;
  } else {
    return SysDia_Stufe_3;
  }
}
Color? Farbe2Diastole(int Wert) {
  if ( Wert == -1 ) {
    return BgColorNeutral;
  } else if ( Wert<80 ) {
    return SysDia_optimal_blass;
  } else if ( Wert >= 80 && Wert < 85 ) {
    return SysDia_normal_blass;
  } else if ( Wert >= 85 && Wert < 90 ) {
    return SysDia_hochnormal_blass;
  } else if ( Wert >= 90 && Wert < 100 ) {
    return SysDia_Stufe_1_blass;
  } else if ( Wert >= 100 && Wert < 110 ) {
    return SysDia_Stufe_2_blass;
  } else {
    return SysDia_Stufe_3_blass;
  }
}

Color Farbe1Puls(int Wert) {
  if ( Wert == -1 ) {
    return BgColorNeutral;
  } else if ( Wert > 0 && Wert < 60 ) {
    return Puls_langsam;
  } else if ( Wert >= 60 && Wert < 100 ) {
    return Puls_normal;
  } else {
    return Puls_schnell;
  }
}
Color? Farbe2Puls(int Wert) {
  if ( Wert == -1 ) {
    return BgColorNeutral;
  } else if ( Wert > 0 && Wert < 60 ) {
    return Puls_langsam_blass;
  } else if ( Wert >= 60 && Wert < 100 ) {
    return Puls_normal_blass;
  } else {
    return Puls_schnell_blass;
  }
}

Color Farbe1Gewicht(String Wert) {
  if ( Wert.length > 0 ) {
    var w = double.tryParse(Wert);
    if ( w != null && w >= 0.0 ) {
      return Gewicht_normal;
    } else {
      return BgColorNeutral;
    }
  } else {
    return BgColorNeutral;
  }
}
Color? Farbe2Gewicht(String Wert) {
  if ( Wert.length > 0 ) {
    var w = double.tryParse(Wert);
    if ( w != null && w >= 0.0 ) {
      return Gewicht_normal_blass;
    } else {
      return BgColorNeutral;
    }
  } else {
    return BgColorNeutral;
  }
}

bool isNumeric(String val) {
  try {
    var regex = RegExp(r'\d+');
    if ( val.contains(regex) == false ) {
      return false;
    }
    return true;
  } catch (_, e) {
    return false;
  }
}
