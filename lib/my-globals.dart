library globals;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

PackageInfo gPackageInfo = PackageInfo(appName: "", packageName: "", version: "", buildNumber: "");
int screenwidth = 0;
int screenheight = 0;
String lokalDBDir = "/sdcard/";
String lokalDBPfad = lokalDBDir + "SysDiaPuls/";
String lokalDBNameOhnePfad = "SysDiaPuls.db";
String lokalDBNameMitPfad = lokalDBPfad + lokalDBNameOhnePfad;

// Farbdefinitionen
Color BgColorNeutral = Colors.white;

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
