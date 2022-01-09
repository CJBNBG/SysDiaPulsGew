import 'dart:io';
import 'package:sysdiapulsgew/services/DataInterface.dart';
import 'package:sysdiapulsgew/services/SettingsInterface.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:flutter/foundation.dart';
import '../../my-globals.dart' as globals;

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
        if (kDebugMode) {
          print( DateTime.now().toString() + " - Datenbank geöffnet");
        }
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
    if (kDebugMode) {
      print( DateTime.now().toString() + " - istDB_OK(): Datenbank geschlossen");
    }
    retVal = true;

    return retVal;
  }

  // Die Datenbank importieren
  // -------------------------
  static Future<bool> importiereDatenbank(String strDBName) async {
    if (kDebugMode) {
      print( DateTime.now().toString() + " - importiere Datenbank aufgerufen");
    }
    String strQuelle = globals.lokalDBPfad + strDBName;
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
        Future<File> f = new File(strQuelle).copy(strZiel);
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

  // die Datenbank exportieren
  // -------------------------
  static Future<bool> exportiereDatenbank() async {
    print( DateTime.now().toString() + " - exportiere Datenbank aufgerufen");
    String frompath = await sql.getDatabasesPath();
    //String topath = await Directory(globals.lokalDBNameMitPfad).toString();
    DateTime jetzt = DateTime.now();
    String strJahr = jetzt.year.toString();
    if (strJahr.length < 4) strJahr = '20' + strJahr;
    String strMonat = jetzt.month.toString();
    if (strMonat.length < 2) strMonat = '0' + strMonat;
    String strTag = jetzt.day.toString();
    if (strTag.length < 2) strTag = '0' + strTag;
    String strStunde = jetzt.hour.toString();
    if (strStunde.length < 2) strStunde = '0' + strStunde;
    String strMinute = jetzt.minute.toString();
    if (strMinute.length < 2) strMinute = '0' + strMinute;
    String strSekunde = jetzt.second.toString();
    if (strSekunde.length < 2) strSekunde = '0' + strSekunde;
    String strMillisekunde = jetzt.millisecond.toString();
    if (strMillisekunde.length < 2) {
      strMillisekunde = '00' + strMillisekunde;
    } else
    if (strMillisekunde.length < 3) {
      strMillisekunde = '0' + strMillisekunde;
    }
    String strZiel = globals.lokalDBPfad + strJahr + strMonat + strTag + "_" + strStunde +
        strMinute + "_" + strSekunde + strMillisekunde + "_V" +
        _databaseVersion.toString() + "_" + globals.lokalDBNameOhnePfad;
    String strQuelle = frompath + "/" + globals.lokalDBNameOhnePfad;
    try {
      final db = await dbHelper.db();
      if ( db.isOpen ) {
        await db.close();
        if (kDebugMode) {
          print( DateTime.now().toString() + " - exportiereDatenbank(): Datenbank geschlossen");
        }
      }
      if ( Directory(globals.lokalDBPfad).exists() == true ) {
        Future<File> f = new File(strQuelle).copy(strZiel);
        if (f != null) {
          if (kDebugMode) {
            print( DateTime.now().toString() + " - Datenbank exportiert: " + strZiel);
          }
          return true;
        } else {
          if (kDebugMode) {
            print( DateTime.now().toString() + " - Datenbank NICHT exportiert: " + strZiel);
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print( DateTime.now().toString() + " - Das Zielverzeichnis existiert nicht: " + globals.lokalDBPfad);
        }
        return false;
      }
    } on Error catch( _, e ){
      if (kDebugMode) {
        print( DateTime.now().toString() + " - Fehler beim Exportieren der Datei: " + strZiel + ": $e");
      }
      return false;
    }
  }

  // Daten-Tabelle
  // -------------

  // Anzahl Einträge
  static Future<List<Map<String, dynamic>>> getEntryCount() async {
    final db = await dbHelper.db();
    String SQL_Statement = "SELECT Count(*) AS Cnt FROM tDaten";
    final result = await db.rawQuery(SQL_Statement, []);
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - getEntryCount(): Datenbank geschlossen - $result");
    }
    return result;
  }

  // letzter Eintrag
  static Future<List<Map<String, dynamic>>> getLastEntry() async {
    final db = await dbHelper.db();
    final id = await db.rawQuery("SELECT pid FROM tDaten WHERE Zeitpunkt=(SELECT MAX(Zeitpunkt) FROM tDaten)", []);
    print( DateTime.now().toString() + " - getLastEntry(): pid - $id");
    final result = await db.query(DataInterface.tblData, where: DataInterface.colID + " = ?", whereArgs: [id[0]['pid']], limit: 1);
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - getLastEntry(): Datenbank geschlossen - $result");
    }
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
    final id = await db.insert(DataInterface.tblData, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - createDataItem(): Datenbank geschlossen - $id");
    }
    return id;
  }

  // alle Einträge nach Zeitpunkt sortiert
  static Future<List<Map<String, dynamic>>> getDataItems(int Lmt) async {
    final db = await dbHelper.db();
    if ( Lmt > 0 ) {
      final result = await db.query(DataInterface.tblData, orderBy: DataInterface.colZeitpunkt + ' DESC', limit: Lmt);
      await db.close();
      if (kDebugMode) {
        print( DateTime.now().toString() + " - getDataItems($Lmt): Datenbank geschlossen - $result");
      }
      return result;
    }
    else {
      final result = await db.query(DataInterface.tblData, orderBy: DataInterface.colZeitpunkt + ' DESC');
      await db.close();
      if (kDebugMode) {
        print( DateTime.now().toString() + " - getDataItems(): Datenbank geschlossen - $result");
      }
      return result;
    }
  }

  // der Eintrag mit der angegebenen ID
  static Future<List<Map<String, dynamic>>> getDataItem(int id) async {
    final db = await dbHelper.db();
    final result = await db.query(DataInterface.tblData, where: DataInterface.colID + " = ?", whereArgs: [id], limit: 1);
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - getDataItem($id): Datenbank geschlossen - $result");
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
    final result = await db.rawQuery(SQL_Statement, []);
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - getDataDaysCount($Tage): Datenbank geschlossen - $result");
    }
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
    final result = await db.rawQuery(SQL_Statement);
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - getDataDays($Tage): Datenbank geschlossen - $result");
    }
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

    final result = await db.update(DataInterface.tblData, data, where: DataInterface.colID + " = ?", whereArgs: [id]);
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - updateDataItem($id): Datenbank geschlossen - $result");
    }
    return result;
  }

  // den Eintrag mit der angegebenen ID löschen
  static Future<void> deleteDataItem(int id) async {
    final db = await dbHelper.db();
    try {
      final result = await db.delete(DataInterface.tblData, where: DataInterface.colID + " = ?", whereArgs: [id]);
      await db.close();
      if (kDebugMode) {
        print( DateTime.now().toString() + " - deleteDataItem($id): Datenbank geschlossen - $result");
      }
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
    final result = await db.rawQuery(SQL_Statement, args);
    await db.close();
    print(result);
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
    if (kDebugMode) {
      print( DateTime.now().toString() + " - getAVGVonBis($Was, $von, $bis, $anzTage): Datenbank geschlossen - $sRet");
    }
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
    if (kDebugMode) {
      print( DateTime.now().toString() + " - createSettingsItem($id): Datenbank geschlossen");
    }
    return id;
  }

  // alle Einträge nach Bezeichnung sortiert
  static Future<List<Map<String, dynamic>>> getSettingsItems() async {
    final db = await dbHelper.db();
    final result = await db.query(SettingsInterface.tblData, orderBy: SettingsInterface.colBezeichnung);
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - getSettingsItems(): Datenbank geschlossen - $result");
    }
    return result;
  }

  // der Eintrag mit der angegebenen ID
  static Future<List<Map<String, dynamic>>> getSettingsItem(int id) async {
    final db = await dbHelper.db();
    final result = await db.query(SettingsInterface.tblData, where: SettingsInterface.colID + " = ?", whereArgs: [id], limit: 1);
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - getSettingsItem($id): Datenbank geschlossen - $result");
    }
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
    if (kDebugMode) {
      print( DateTime.now().toString() + " - updateSettingsItem($id): Datenbank geschlossen - $result");
    }
    return result;
  }

  // den Eintrag mit der angegebenen ID löschen
  static Future<void> deleteSettingsItem(int id) async {
    final db = await dbHelper.db();
    try {
      final result = await db.delete(SettingsInterface.tblData, where: SettingsInterface.colID + " = ?", whereArgs: [id]);
      await db.close();
      if (kDebugMode) {
        print( DateTime.now().toString() + " - deleteSettingsItem($id): Datenbank geschlossen - $result");
      }
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
    } catch (err) {
      if (kDebugMode) {
        print("Fehler beim Bestimmen der Anzahl getTabEntryCount " + err.toString());
      }
    }
    if ( theList.length > 0 ) {
      Result = theList[0]['cnt'];
    }
    await db.close();
    if (kDebugMode) {
      print( DateTime.now().toString() + " - getTabEntryCount(): Datenbank geschlossen - $Result");
    }
    return Result;
  }
}