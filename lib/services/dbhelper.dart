import 'dart:io';
import 'package:sysdiapulsgew/services/DataInterface.dart';
import 'package:sysdiapulsgew/services/SettingsInterface.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:flutter/foundation.dart';
import '../../my-globals.dart' as globals;
import '../pages/DiagramPage/diagrampage.dart';

class dbHelper {
  static const _databaseVersion = 1;

  static Future _onCreateDB(sql.Database db) async {
    //create tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DataInterface.tblData}(
        ${DataInterface.colID} INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        ${DataInterface.colZeitpunkt} DATETIME NOT NULL,
        ${DataInterface.colSystole} INTEGER NOT NULL,
        ${DataInterface.colDiastole} INTEGER NOT NULL,
        ${DataInterface.colPuls} INTEGER NULL,
        ${DataInterface.colGewicht} FLOAT NULL,
        ${DataInterface.colBemerkung} TEXT NULL
      )
      ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${SettingsInterface.tblData}(
        ${SettingsInterface.colID} INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        ${SettingsInterface.colBezeichnung} TEXT NOT NULL,
        ${SettingsInterface.colTyp} TEXT NOT NULL,
        ${SettingsInterface.colWertInt} INTEGER NULL,
        ${SettingsInterface.colWertFloat} FLOAT NULL,
        ${SettingsInterface.colWertText} TEXT NULL
      )
      ''');
    if (kDebugMode) {
      print( DateTime.now().toString() + " - Datenbank _onCreateDB");
    }
  }

  static Future<sql.Database> db() async {
    sql.Database myDB = await sql.openDatabase(
      globals.lokalDBNameOhnePfad,
      version: _databaseVersion,
      onOpen: (sql.Database thisdb) async {
        // if (kDebugMode) {
        //   print( DateTime.now().toString() + " - Datenbank geöffnet");
        // }
      },
      onCreate: (sql.Database thisdb, int ver) async {
        await _onCreateDB(thisdb);
      },
    );
    return myDB;
  }

  // prüft, ob die benötigten Einstellungen in der Tabelle tSettings vorhanden sind
  static Future<bool> istDB_OK() async {
    bool retVal = false;

    int anz = await getTabEntryCount();
    final db = await dbHelper.db();
    if ( anz == -1 ) {
      final data = {
        SettingsInterface.colBezeichnung: 'AnzTabEintraege',
        SettingsInterface.colTyp: 'INT',
        SettingsInterface.colWertInt: 50
      };
      final int id = await db.insert(SettingsInterface.tblData, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
      if (kDebugMode) {
        print(DateTime.now().toString() + " - AnzTabEintraege erzeugt $id");
      }
    } else {
      if (kDebugMode) {
        print(DateTime.now().toString() + " - AnzTabEintraege=$anz");
      }
    }
    await db.close();

    int anzDD = await getDiagramDaysCount();
    final dbDD = await dbHelper.db();
    if ( anzDD == -1 ) {
      final data = {
        SettingsInterface.colBezeichnung: 'AnzDiagrammEintraege',
        SettingsInterface.colTyp: 'INT',
        SettingsInterface.colWertInt: 7
      };
      final int id = await dbDD.insert(SettingsInterface.tblData, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
      if (kDebugMode) {
        print(DateTime.now().toString() + " - AnzDiagrammEintraege erzeugt $id");
      }
    } else {
      if (kDebugMode) {
        print(DateTime.now().toString() + " - AnzDiagrammEintraege=$anzDD");
      }
    }
    await dbDD.close();

    double aktGr = await getGroesse();
    final dbGr = await dbHelper.db();
    if ( aktGr == -1 ) {
      final data = {
        SettingsInterface.colBezeichnung: 'Groesse',
        SettingsInterface.colTyp: 'FLOAT',
        SettingsInterface.colWertFloat: 181.0
      };
      final int id = await dbGr.insert(SettingsInterface.tblData, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
      if (kDebugMode) {
        print(DateTime.now().toString() + " - Groesseneintrag erzeugt $id");
      }
    } else {
      if (kDebugMode) {
        print(DateTime.now().toString() + " - Groesse=$aktGr");
      }
    }
    await dbGr.close();
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - istDB_OK(): Datenbank geschlossen");
    // }
    retVal = true;

    return retVal;
  }

  // Die Datenbank importieren
  // -------------------------
  static Future<bool> importiereDatenbank(String strDBName) async {
    String strQuelle = strDBName;
    String strZiel = await sql.getDatabasesPath() + "/" + globals.lokalDBNameOhnePfad;
    try {
      final db = await dbHelper.db();
      if ( db.isOpen ) {
        await db.close();
        if (kDebugMode) {
          print( DateTime.now().toString() + " - importiereDatenbank(): Datenbank geschlossen");
        }
      }
      if ( await File(strQuelle).exists() == true ) {
        File sourceFile = File(strDBName);
        var f =  await moveFile(sourceFile,await strZiel);
        // Future<File> f = new File(strQuelle).copy(strZiel);
        if (f != null) {
          if (kDebugMode) {
            print( DateTime.now().toString() + " - Datenbank importiert: " + strDBName);
          }
          return true;
        }
        else {
          if (kDebugMode) {
            print( DateTime.now().toString() + " - Datenbank NICHT importiert: " + strDBName);
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print( DateTime.now().toString() + " - Die zu importierende Datei existiert nicht: " + strQuelle);
        }
        return false;
      }
    } on Error catch( _, e ){
      if (kDebugMode) {
        print( DateTime.now().toString() + " - Fehler beim Importieren der Datei: " + strZiel + ": $e");
      }
      return false;
    }
  }
  static Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      /// prefer using rename as it is probably faster
      /// if same directory path
      print("sourceFile=$sourceFile");
      print("newPath=$newPath");
      return await sourceFile.rename(newPath);
    } catch (e) {
      /// if rename fails, copy the source file
      final newFile = await sourceFile.copy(newPath);
      return newFile;
    }
  }
  // die Datenbank exportieren
  // -------------------------
  static Future<bool> exportiereDatenbank() async {
    print( "${DateTime.now()} - exportiere Datenbank aufgerufen");
    String frompath = await sql.getDatabasesPath();
    String toPath = globals.lokalDBPfad;
    DateTime jetzt = DateTime.now();
    String strJahr = jetzt.year.toString();
    if (strJahr.length < 4) strJahr = '20$strJahr';
    String strMonat = jetzt.month.toString();
    if (strMonat.length < 2) strMonat = '0$strMonat';
    String strTag = jetzt.day.toString();
    if (strTag.length < 2) strTag = '0$strTag';
    String strStunde = jetzt.hour.toString();
    if (strStunde.length < 2) strStunde = '0$strStunde';
    String strMinute = jetzt.minute.toString();
    if (strMinute.length < 2) strMinute = '0$strMinute';
    String strSekunde = jetzt.second.toString();
    if (strSekunde.length < 2) strSekunde = '0$strSekunde';
    String strMillisekunde = jetzt.millisecond.toString();
    if (strMillisekunde.length < 2) {
      strMillisekunde = '00$strMillisekunde';
    } else
    if (strMillisekunde.length < 3) {
      strMillisekunde = '0$strMillisekunde';
    }
    String strZiel = "$toPath${strJahr}${strMonat}${strTag}_$strStunde${strMinute}_$strSekunde${strMillisekunde}_V${_databaseVersion}_${globals.lokalDBNameOhnePfad}";
    String strQuelle = "$frompath/${globals.lokalDBNameOhnePfad}";
    try {
      // es muss sichergestellt sein, dass die Datenbank geschlossen ist
      final db = await dbHelper.db();
      if ( db.isOpen ) {
        await db.close();
      }
      // feststellen, ob das Zielverzeichnis existiert
      if ( await Directory(globals.lokalDBPfad).exists() == false ) {
        var resDir = await Directory(globals.lokalDBPfad).create(recursive: true);
        if ( resDir.isAbsolute ) {
          if (kDebugMode) {
            print("resDir.uri.userinfo=${resDir.uri.userInfo}");
          }
        }
      }
      if ( await Directory(globals.lokalDBPfad).exists() == true ) {
        Future<File> f = new File(strQuelle).copy(strZiel);
        if (f != null) {
          if (kDebugMode) {
            print( "${DateTime.now()} - Datenbank exportiert: $strZiel");
          }
          return true;
        } else {
          if (kDebugMode) {
            print( "${DateTime.now()} - Datenbank NICHT exportiert: $strZiel");
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print( "${DateTime.now()} - Das Zielverzeichnis existiert nicht: ${globals.lokalDBPfad}");
        }
        return false;
      }
    } on Error catch( _, e ){
      if (kDebugMode) {
        print( "${DateTime.now()} - Fehler beim Exportieren der Datei: $strZiel: $e");
      }
      return false;
    }
  }

  // Daten-Tabelle
  // -------------

  // Anzahl Einträge
  static Future<int?> getEntryCount() async {
    int? retAnz = 0;
    final db = await dbHelper.db();
    try {
      var result;
      if ( db.isOpen ) {
        String SQL_Statement = "SELECT Count(*) AS Cnt FROM tDaten";
        result = await db.rawQuery(SQL_Statement, []);
        if ( result.isNotEmpty ) {
          retAnz = int.tryParse(result[0]['Cnt'].toString());
        } else {
          retAnz = 0;
        }
      } else {
        print('getEntryCount: Datenbank konnte nicht geöffnet werden');
      }
    } catch(e) {
      print('getEntryCount: Fehler bei der Ermittlung der Anzahl an Einträgen $e');
    } finally {
      await db.close();
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getEntryCount(): Datenbank geschlossen - $result");
    // }
    return retAnz;
  }

  // Diagramm: Systole
  static Future<List<ChartData>> getWertFuerDiagramm(String xSys, String xDia, int xTage) async {
    List<ChartData>retval = [];
    String strsql = "";
    try {
      final db = await dbHelper.db();
      DateTime t1 = DateTime.now();
      DateTime t2 = DateTime.now();
      if ( xTage < 0 ) {
        t1 = t1.add(Duration(days: xTage));
      } else {
        t2 = t2.add(Duration(days: xTage));
      }
      t1 = DateTime(t1.year, t1.month, t1.day, 0, 0, 0);
      t2 = DateTime(t2.year, t2.month, t2.day, 23, 59, 59);
      strsql = "SELECT $xSys, $xDia, strftime('%H', Zeitpunkt) as Zeitpkt_H, strftime('%M', Zeitpunkt) as Zeitpkt_M FROM tDaten";
      strsql += " WHERE Zeitpunkt BETWEEN '${t1.toIso8601String()}' AND '${t2.toIso8601String()}'";
      strsql += " ORDER BY Zeitpkt_H, Zeitpkt_M";
      // if (kDebugMode) {
      //   print(DateTime.now().toString() + " - getWertFuerDiagramm($xWert, $xTage): $strsql");
      // }
      final result = await db.rawQuery(strsql, []);
      if ( result.isNotEmpty ) {
        int _y_Sys, _y_Dia;
        int _std, _min;
        DateTime _stdmin;
        ChartData _p;
        for (var element in result) {
          _y_Sys = int.tryParse(element[xSys].toString()) as int;
          _y_Dia = int.tryParse(element[xDia].toString()) as int;
          _std = int.tryParse(element['Zeitpkt_H'].toString())!;
          _min = int.tryParse(element['Zeitpkt_M'].toString())!;
          _stdmin = DateTime(2000,1,1,_std,_min);
          // _stdmin = _std.toString() + ':' + _min.toString();
          _p = ChartData(_stdmin, _y_Sys, _y_Dia);
          retval.add(_p);
        }
        // if (kDebugMode) {
        //   print(DateTime.now().toString() + " - getWertFuerDiagramm($xWert, $xTage): ${result.length} Punkte eingelesen");
        // }
      } else {
        // if (kDebugMode) {
        //   print(DateTime.now().toString() + " - getWertFuerDiagramm($xWert, $xTage): keine Daten");
        // }
      }
      await db.close();
      // if (kDebugMode) {
      //   print(DateTime.now().toString() + " - getWertFuerDiagramm($xWert, $xTage): Datenbank geschlossen");
      // }
    } catch ( _, err ) {
      if (kDebugMode) {
        print("Fehler in getSysDiagramm($xSys, $xTage): $err");
      }
    }
    return retval;
  }

  // erster Eintrag
  static Future<List<Map<String, dynamic>>> getFirstEntry() async {
    final db = await dbHelper.db();
    var result;
    if ( db.isOpen ) {
      result = await db.rawQuery("SELECT strftime('%Y-%m-%d %H:%M', Zeitpunkt) as Zeitpkt, * FROM tDaten WHERE Zeitpunkt=(SELECT MIN(Zeitpunkt) FROM tDaten)", []);
      await db.close();
    } else {
      print('getLastEntry: Datenbank konnte nicht geöffnet werden');
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getFirstEntry(): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // letzter Eintrag
  static Future<List<Map<String, dynamic>>> getLastEntry() async {
    final db = await dbHelper.db();
    var result;
    if ( db.isOpen ) {
      result = await db.rawQuery("SELECT strftime('%d.%m.%Y %H:%M', Zeitpunkt) as Zeitpkt, * FROM tDaten WHERE Zeitpunkt=(SELECT MAX(Zeitpunkt) FROM tDaten)", []);
      await db.close();
    } else {
      print('getLastEntry: Datenbank konnte nicht geöffnet werden');
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getLastEntry(): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // neuer Eintrag
  static Future<int> createDataItem(String Zeitpunkt, int Systole, int Diastole, int? Puls, double? Gewicht, String? Bemerkung) async {
    final db = await dbHelper.db();
    final data = {DataInterface.colZeitpunkt: Zeitpunkt,
                  DataInterface.colSystole: Systole,
                  DataInterface.colDiastole: Diastole,
                  DataInterface.colPuls: Puls,
                  DataInterface.colGewicht: Gewicht,
                  DataInterface.colBemerkung: Bemerkung};
    var id;
    if ( db.isOpen ) {
      id = await db.insert(DataInterface.tblData, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
      await db.close();
    } else {
      print('createDataItem: Datenbank konnte nicht geöffnet werden');
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - createDataItem(): Datenbank geschlossen - $id");
    // }
    return id;
  }

  // alle Tage, an denen Einträge existieren, abstiegend sotiert
  static Future<List<Map<String, dynamic>>> getOnlyDataDays() async {
    final db = await dbHelper.db();
    var result;
    if ( db.isOpen ) {
      result = await db.rawQuery("SELECT DISTINCT strftime('%Y-%m-%d', Zeitpunkt) as Zeitpkt FROM tDaten ORDER BY Zeitpunkt DESC", []);
      await db.close();
    } else {
      print('getOnlyDataDays: Datenbank konnte nicht geöffnet werden');
    }
    return result;
  }
  // alle Einträge nach Zeitpunkt sortiert
  static Future<List<Map<String, dynamic>>> getDataItems(int Lmt) async {
    final db = await dbHelper.db();
    var result;
    if ( db.isOpen ) {
      if ( Lmt > 0 ) {
        result = await db.query(DataInterface.tblData, orderBy: DataInterface.colZeitpunkt + ' DESC', limit: Lmt);
      }
      else {
        result = await db.query(DataInterface.tblData, orderBy: DataInterface.colZeitpunkt + ' DESC');
      }
      await db.close();
    } else {
      print('getDataItems: Datenbank konnte nicht geöffnet werden');
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getDataItems($Lmt): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // der Eintrag mit der angegebenen ID
  static Future<List<Map<String, dynamic>>> getDataItem(int id) async {
    final db = await dbHelper.db();
    var result;
    if ( db.isOpen ) {
      result = await db.query(DataInterface.tblData, where: DataInterface.colID + " = ?", whereArgs: [id], limit: 1);
      await db.close();
    } else {
      print('getDataItem: Datenbank konnte nicht geöffnet werden');
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getDataItem($id): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // der Eintrag des angegebenen Datums
  static Future<List<Map<String, dynamic>>> getDataItemsForDay(DateTime day) async {
    List<Map<String, dynamic>> result = [];
    try {
      final db = await dbHelper.db();
      if ( db.isOpen ) {
        String SQL_Statement = "SELECT * FROM tDaten WHERE Zeitpunkt BETWEEN '${day.toString()}' AND '${day.add(Duration(days: 1)).toString()}'";
        result = await db.rawQuery(SQL_Statement, []);
        await db.close();
      } else {
        print('getDataItemsForDay: Datenbank konnte nicht geöffnet werden');
      }
      // if (kDebugMode) {
      //   print( DateTime.now().toString() + " - getDataItemsForDay(${SQL_Statement}): Datenbank geschlossen - $result");
      // }
    } on Error catch ( _, e ) {
      print( 'Fehler in getDataItemsForDay: $e');
    }
    return result;
  }

  // letzter Eintrag
  static Future<List<Map<String, dynamic>>> getDataDaysCount(int Tage) async {
    final db = await dbHelper.db();

    String SQL_Statement = "SELECT Count(*) AS Cnt FROM tDaten";
    SQL_Statement += " WHERE Zeitpunkt BETWEEN";
    if ( Tage < 0 ) {
      SQL_Statement += " (SELECT MAX(Zeitpunkt)" + Tage.toString() + " FROM tDaten)";
      SQL_Statement += " AND";
      SQL_Statement += " (SELECT MAX(Zeitpunkt) FROM tDaten)";
    } else {
      SQL_Statement += " (SELECT MAX(Zeitpunkt) FROM tDaten)";
      SQL_Statement += " AND";
      SQL_Statement += " (SELECT MAX(Zeitpunkt)" + Tage.toString() + " FROM tDaten)";
    }
    var result;
    if ( db.isOpen ) {
      result = await db.rawQuery(SQL_Statement, []);
      await db.close();
    } else {
      print('getDataDaysCount: Datenbank konnte nicht geöffnet werden');
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getDataDaysCount($Tage): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // alle Einträge der letzten angegebenen Anzahl von Tagen
  static Future<List<Map<String, dynamic>>> getDataDays(int Tage) async {
    final db = await dbHelper.db();

    String SQL_Statement = "SELECT printf('%.2f',AVG(Systole)) AS SysAVG";
    SQL_Statement += ", printf('%.2f',AVG(Diastole)) AS DiaAVG";
    SQL_Statement += ", printf('%.2f',AVG(Puls)) AS PulsAVG";
    SQL_Statement += " FROM tDaten";
    SQL_Statement += " WHERE Zeitpunkt BETWEEN";
    if ( Tage < 0 ) {
      SQL_Statement += " (SELECT MAX(Zeitpunkt)" + Tage.toString() + " FROM tDaten)";
      SQL_Statement += " AND";
      SQL_Statement += " (SELECT MAX(Zeitpunkt) FROM tDaten)";
    } else {
      SQL_Statement += " (SELECT MAX(Zeitpunkt) FROM tDaten)";
      SQL_Statement += " AND";
      SQL_Statement += " (SELECT MAX(Zeitpunkt)" + Tage.toString() + " FROM tDaten)";
    }
    var result;
    if ( db.isOpen ) {
      result = await db.rawQuery(SQL_Statement);
      await db.close();
    } else {
      print('getDataDays: Datenbank konnte nicht geöffnet werden');
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getDataDays($Tage): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // den Eintrag mit der angegebenen ID ändern
  // required: Systole, Diastole, Puls
  // voluntary: Zeitpunkt, Gewicht, Bemerkung
  static Future<int> updateDataItem(
      int id,
      int Systole, int Diastole, int Puls,
      String Zeitpunkt,
      double? Gewicht,
      String? Bemerkung) async {
    final db = await dbHelper.db();

    final data = {DataInterface.colZeitpunkt: Zeitpunkt,
      DataInterface.colSystole: Systole,
      DataInterface.colDiastole: Diastole,
      DataInterface.colPuls: Puls,
      DataInterface.colGewicht: Gewicht,
      DataInterface.colBemerkung: Bemerkung
    };

    var result;
    if ( db.isOpen ) {
      result = await db.update(DataInterface.tblData, data, where: DataInterface.colID + " = ?", whereArgs: [id]);
      await db.close();
    } else {
      print('updateDataItem: Datenbank konnte nicht geöffnet werden');
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - updateDataItem($id): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // den Eintrag mit der angegebenen ID löschen
  static Future<void> deleteDataItem(int id) async {
    final db = await dbHelper.db();
    try {
      final result = await db.delete(DataInterface.tblData, where: DataInterface.colID + " = ?", whereArgs: [id]);
      await db.close();
      // if (kDebugMode) {
      //   print( DateTime.now().toString() + " - deleteDataItem($id): Datenbank geschlossen - $result");
      // }
    } catch (err) {
      debugPrint("Irgendetwas ging schief beim Löschen des Daten-Eintrags: $err");
    }
  }

  // Mittelwerte
  // -----------
  static Future<String> getAVGVonBis(String Was, String von, String bis, String anzTage) async {
    final db = await dbHelper.db();
    List args = [von, bis];

    String SQL_Statement = "SELECT AVG($Was) AS erg FROM tDaten WHERE strftime('%H:%M', Zeitpunkt) BETWEEN ? AND ?";
    if ( anzTage != 'alle' ) {
      DateTime Jetzt = DateTime.now();
      int Jahr = Jetzt.year;
      int Monat = Jetzt.month;
      int Tag = Jetzt.day;
      int? Zeitoffset = int.tryParse(anzTage);
      DateTime Zeit2 = DateTime(Jahr, Monat,Tag+Zeitoffset!);
      if ( Zeitoffset > 0 ) {
        args.add(Jetzt.toString());
        args.add(Zeit2.toString());
      } else {
        args.add(Zeit2.toString());
        args.add(Jetzt.toString());
      }
      SQL_Statement += " AND Zeitpunkt IN (SELECT Zeitpunkt FROM tDaten";
      SQL_Statement += " WHERE strftime('%Y-%m-%d', Zeitpunkt) BETWEEN ? AND ?)";
    }
    var result;
    if ( db.isOpen ) {
      result = await db.rawQuery(SQL_Statement, args);
      await db.close();
    } else {
      print('getAVGVonBis: Datenbank konnte nicht geöffnet werden');
    }
    // if (kDebugMode) {
    //   print(result);
    // }
    String sRet = "0.0";
    if ( result.isNotEmpty ) {
      if (result[0]['erg'] != null) {
        double? dRet = double.tryParse(result[0]['erg'].toString());
        dRet ??= -1.0;
        sRet = dRet.toStringAsFixed(1);
      } else {
        sRet = "keine Daten";
      }
    } else {
      sRet = "Fehler";
    }
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getAVGVonBis($Was, $von, $bis, $anzTage): Datenbank geschlossen - $sRet");
    // }
    return sRet;
  }

  // Einstellungen-Tabelle
  // ---------------------

  // neuer Eintrag
  static Future<int> createSettingsItem(String Bezeichnung, String Typ, int? Wert_INT, double? Wert_FLOAT, String? Wert_TEXT) async {
    final db = await dbHelper.db();

    final data = {SettingsInterface.colBezeichnung: Bezeichnung,
      SettingsInterface.colTyp: Typ,
      SettingsInterface.colWertInt: Wert_INT,
      SettingsInterface.colWertFloat: Wert_FLOAT,
      SettingsInterface.colWertText: Wert_TEXT};
    final id = await db.insert(SettingsInterface.tblData, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    await db.close();
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - createSettingsItem($id): Datenbank geschlossen");
    // }
    return id;
  }

  // alle Einträge nach Bezeichnung sortiert
  static Future<List<Map<String, dynamic>>> getSettingsItems() async {
    final db = await dbHelper.db();
    final result = await db.query(SettingsInterface.tblData, orderBy: SettingsInterface.colBezeichnung);
    await db.close();
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getSettingsItems(): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // der Eintrag mit der angegebenen ID
  static Future<List<Map<String, dynamic>>> getSettingsItem(int id) async {
    final db = await dbHelper.db();
    final result = await db.query(SettingsInterface.tblData, where: SettingsInterface.colID + " = ?", whereArgs: [id], limit: 1);
    await db.close();
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getSettingsItem($id): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // den Eintrag mit der angegebenen ID ändern
  // required: Typ
  // voluntary: Wert_INT, Wert_FLOAT oder Wert_TEXT
  static Future<int> updateSettingsItem(
      int id,
      String Bezeichnung,
      String Typ,
      int? Wert_INT,
      double? Wert_FLOAT,
      String? Wert_TEXT) async {
    final db = await dbHelper.db();

    final data = {
      SettingsInterface.colBezeichnung: Bezeichnung,
      SettingsInterface.colTyp: Typ,
      SettingsInterface.colWertInt: Wert_INT,
      SettingsInterface.colWertFloat: Wert_FLOAT,
      SettingsInterface.colWertText: Wert_TEXT
    };

    final result = await db.update(SettingsInterface.tblData, data, where: SettingsInterface.colID + " = ?", whereArgs: [id]);
    await db.close();
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - updateSettingsItem($id): Datenbank geschlossen - $result");
    // }
    return result;
  }

  // den Eintrag mit der angegebenen ID löschen
  static Future<void> deleteSettingsItem(int id) async {
    final db = await dbHelper.db();
    try {
      final result = await db.delete(SettingsInterface.tblData, where: SettingsInterface.colID + " = ?", whereArgs: [id]);
      await db.close();
      // if (kDebugMode) {
      //   print( DateTime.now().toString() + " - deleteSettingsItem($id): Datenbank geschlossen - $result");
      // }
    } catch (err) {
      if (kDebugMode) {
        print("Irgendetwas ging schief beim Löschen des Einstellungs-Eintrags: $err");
      }
    }
  }

  // den Eintrag mit der Anzahl der Einträge in der Tabelle ermitteln
  static Future<int> getTabEntryCount() async {
    int Result = -1;
    List<Map<String, dynamic>> theList = [];
    final db = await dbHelper.db();

    try {
      theList = await db.rawQuery("SELECT Wert_INT AS cnt FROM tSettings WHERE Bezeichnung LIKE 'AnzTabEintraege' AND Typ='INT'");
    } on Error catch (err) {
      if (kDebugMode) {
        print("Fehler beim Bestimmen der Anzahl getTabEntryCount " + err.toString());
      }
    }
    if ( theList.length > 0 ) {
      Result = theList[0]['cnt'];
    }
    await db.close();
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getTabEntryCount(): Datenbank geschlossen - $Result");
    // }
    return Result;
  }

  static Future<bool> setTabEntryCount(int newCount) async {
    bool Result = false;
    int _ID = -1;
    final db = await dbHelper.db();
    List<Map<String, dynamic>>ret = [];

    try {
      ret = await db.rawQuery("SELECT " + SettingsInterface.colID + " as _ID FROM tSettings WHERE Bezeichnung LIKE 'AnzTabEintraege' AND Typ='INT'");
    } on Error catch (err) {
      if (kDebugMode) {
        print("Fehler beim Bestimmen der Anzahl getTabEntryCount " + err.toString());
      }
    }
    if ( ret.length > 0 ) {
      _ID = ret[0]['_ID'];
    }
    await db.close();
    Result = (await updateSettingsItem(_ID, "AnzTabEintraege", "INT", newCount, null, null) > 0);
    if (kDebugMode) {
      print( DateTime.now().toString() + " - setTabEntryCount($newCount): Datenbank geschlossen - $Result");
    }
    return Result;
  }

  // den Eintrag mit der Anzahl der Einträge in der Tabelle ermitteln
  static Future<int> getDiagramDaysCount() async {
    int Result = -1;
    List<Map<String, dynamic>> theList = [];
    final db = await dbHelper.db();

    try {
      theList = await db.rawQuery("SELECT Wert_INT AS cnt FROM tSettings WHERE Bezeichnung LIKE 'AnzDiagrammEintraege' AND Typ='INT'");
    } on Error catch (err) {
      if (kDebugMode) {
        print("Fehler beim Bestimmen der Anzahl getDiagramDaysCount " + err.toString());
      }
    }
    if ( theList.length > 0 ) {
      Result = theList[0]['cnt'];
    }
    await db.close();
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getTabEntryCount(): Datenbank geschlossen - $Result");
    // }
    return Result;
  }

  static Future<bool> setDiagramDaysCount(int newCount) async {
    bool Result = false;
    int _ID = -1;
    final db = await dbHelper.db();
    List<Map<String, dynamic>>ret = [];

    try {
      ret = await db.rawQuery("SELECT " + SettingsInterface.colID + " as _ID FROM tSettings WHERE Bezeichnung LIKE 'AnzDiagrammEintraege' AND Typ='INT'");
    } on Error catch (err) {
      if (kDebugMode) {
        print("Fehler beim Bestimmen der Anzahl setDiagramDaysCount " + err.toString());
      }
    }
    if ( ret.length > 0 ) {
      _ID = ret[0]['_ID'];
    }
    await db.close();
    Result = (await updateSettingsItem(_ID, "AnzDiagrammEintraege", "INT", newCount, null, null) > 0);
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - setTabEntryCount($newCount): Datenbank geschlossen - $Result");
    // }
    return Result;
  }

  // den Eintrag mit der Anzahl der Einträge in der Tabelle ermitteln
  static Future<double> getGroesse() async {
    double Result = -1.0;
    List<Map<String, dynamic>> theList = [];
    final db = await dbHelper.db();

    try {
      theList = await db.rawQuery("SELECT Wert_FLOAT AS gr FROM tSettings WHERE Bezeichnung LIKE 'Groesse' AND Typ='FLOAT'");
    } on Error catch (err) {
      if (kDebugMode) {
        print("Fehler beim Bestimmen der Groesse " + err.toString());
      }
    }
    if ( theList.length > 0 ) {
      Result = theList[0]['gr'];
    }
    await db.close();
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - getTabEntryCount(): Datenbank geschlossen - $Result");
    // }
    return Result;
  }

  static Future<bool> setGroesse(double neueGroesse) async {
    bool Result = false;
    int _ID = -1;
    final db = await dbHelper.db();
    List<Map<String, dynamic>>ret = [];

    try {
      ret = await db.rawQuery("SELECT " + SettingsInterface.colID + " as _ID FROM tSettings WHERE Bezeichnung LIKE 'Groesse' AND Typ='FLOAT'");
    } on Error catch (err) {
      if (kDebugMode) {
        print("Fehler beim Bestimmen der Groesse " + err.toString());
      }
    }
    if ( ret.length > 0 ) {
      _ID = ret[0]['_ID'];
    }
    await db.close();
    Result = (await updateSettingsItem(_ID, "Groesse", "FLOAT", null, neueGroesse, null) > 0);
    // if (kDebugMode) {
    //   print( DateTime.now().toString() + " - setTabEntryCount($newCount): Datenbank geschlossen - $Result");
    // }
    return Result;
  }
}