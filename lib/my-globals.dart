library globals;

import 'package:package_info_plus/package_info_plus.dart';

PackageInfo gPackageInfo = PackageInfo(appName: "", packageName: "", version: "", buildNumber: "");
int screenwidth = 0;
int screenheight = 0;
String lokalDBDir = "/sdcard/";
String lokalDBPfad = lokalDBDir + "SysDiaPuls/";
String lokalDBNameOhnePfad = "SysDiaPuls.db";
String lokalDBNameMitPfad = lokalDBPfad + lokalDBNameOhnePfad;