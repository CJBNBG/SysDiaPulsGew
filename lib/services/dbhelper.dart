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
    final data = {SettingsInterface.colBezeichnung: 'AnzTabEintraege',
      SettingsInterface.colTyp: 'INT',
      SettingsInterface.colWertInt: 50};
    await db.insert(SettingsInterface.tblData, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      globals.lokalDBNameOhnePfad,
      version: _databaseVersion,
      onCreate: (sql.Database thisdb, int ver) async {
        await _onCreateDB(thisdb);
      },
    );
  }

  // Die Datenbank importieren
  // -------------------------
  static Future<bool> importiereDatenbank(String strDBName) async {
    String strQuelle = globals.lokalDBPfad + strDBName;
    String strZiel = await sql.getDatabasesPath() + "/" + globals.lokalDBNameOhnePfad;
    try {
      if ( await File(strQuelle).exists() == true ) {
        Future<File> f = new File(strQuelle).copy(strZiel);
        if (f != null) {
          print("Datenbank importiert: " + strDBName);
          return true;
        }
        else {
          return false;
        }
      } else {
        print("Die zu importierende Datei existiert nicht: " + strQuelle);
        return false;
      }
    } on Error catch( _, e ){
      print("Fehler beim Importieren der Datei: " + strZiel );
      return false;
    }
  }

  // die Datenbank exportieren
  // -------------------------
  static Future<bool> exportiereDatenbank() async {
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
    if (strMillisekunde.length < 2)
      strMillisekunde = '00' + strMillisekunde;
    else
    if (strMillisekunde.length < 3) strMillisekunde = '0' + strMillisekunde;
    String strZiel = globals.lokalDBPfad + strJahr + strMonat + strTag + "_" + strStunde +
        strMinute + "_" + strSekunde + strMillisekunde + "_V" +
        _databaseVersion.toString() + "_" + globals.lokalDBNameOhnePfad;
    String strQuelle = frompath + "/" + globals.lokalDBNameOhnePfad;
    try {
      if ( Directory(globals.lokalDBPfad).exists() == true ) {
        Future<File> f = new File(strQuelle).copy(strZiel);
        if (f != null) {
          print("Exportdatei geschrieben: " + strZiel);
          return true;
        } else {
          return false;
        }
      } else {
        print("Das Zielverzeichnis existiert nicht: " + globals.lokalDBPfad);
        return false;
      }
    } on Error catch( _, e ){
      print("Fehler beim schreiben der Exportdatei: " + strZiel );
      return false;
    }
  }

  // Daten-Tabelle
  // -------------

  // Anzahl Einträge
  static Future<List<Map<String, dynamic>>> getEntryCount() async {
    final db = await dbHelper.db();
    String SQL_Statement = "SELECT Count(*) AS Cnt FROM tDaten";
    return db.rawQuery(SQL_Statement, []);
  }

  // letzter Eintrag
  static Future<List<Map<String, dynamic>>> getLastEntry() async {
    final db = await dbHelper.db();
    String SQL_Statement = "SELECT Systole,Diastole,Puls,Gewicht,strftime('%d.%m.%Y %H:%M',Zeitpunkt) AS Zeitpkt FROM tDaten WHERE Zeitpunkt=(SELECT MAX(Zeitpunkt) FROM tDaten)";
    return db.rawQuery(SQL_Statement, []);
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
    print("neuer Eintrag - data: $data");
    final id = await db.insert(DataInterface.tblData, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print("neuer Eintrag - id: $id");
    return id;
  }

  // alle Einträge nach Zeitpunkt sortiert
  static Future<List<Map<String, dynamic>>> getDataItems(int Lmt) async {
    final db = await dbHelper.db();
    if ( Lmt > 0 ) return db.query(DataInterface.tblData, orderBy: DataInterface.colZeitpunkt, limit: Lmt);
    else return db.query(DataInterface.tblData, orderBy: DataInterface.colZeitpunkt);
  }

  // der Eintrag mit der angegebenen ID
  static Future<List<Map<String, dynamic>>> getDataItem(int id) async {
    final db = await dbHelper.db();
    return db.query(DataInterface.tblData, where: DataInterface.colID + " = ?", whereArgs: [id], limit: 1);
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
    return db.rawQuery(SQL_Statement, []);
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
    print(SQL_Statement);
    return db.rawQuery(SQL_Statement);
  }

  // den Eintrag mit der angegebenen ID ändern
  // required: Systole, Diastole, Puls
  // voluntary: Zeitpunkt, Gewicht, Bemerkung
  static Future<int> updateDataItem(
      int id,
      int Systole, int Diastole, int Puls,
      DateTime? Zeitpunkt,
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

    final result =
    await db.update(DataInterface.tblData, data, where: DataInterface.colID + " = ?", whereArgs: [id]);
    return result;
  }

  // den Eintrag mit der angegebenen ID löschen
  static Future<void> deleteDataItem(int id) async {
    final db = await dbHelper.db();
    try {
      await db.delete(DataInterface.tblData, where: DataInterface.colID + " = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Irgendetwas ging schief beim Löschen des Daten-Eintrags: $err");
    }
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
    final id = await db.insert(SettingsInterface.tblData, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // alle Einträge nach Bezeichnung sortiert
  static Future<List<Map<String, dynamic>>> getSettingsItems() async {
    final db = await dbHelper.db();
    return db.query(SettingsInterface.tblData, orderBy: SettingsInterface.colBezeichnung);
  }

  // der Eintrag mit der angegebenen ID
  static Future<List<Map<String, dynamic>>> getSettingsItem(int id) async {
    final db = await dbHelper.db();
    return db.query(SettingsInterface.tblData, where: SettingsInterface.colID + " = ?", whereArgs: [id], limit: 1);
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

    final result =
    await db.update(SettingsInterface.tblData, data, where: SettingsInterface.colID + " = ?", whereArgs: [id]);
    return result;
  }

  // den Eintrag mit der angegebenen ID löschen
  static Future<void> deleteSettingsItem(int id) async {
    final db = await dbHelper.db();
    try {
      await db.delete(SettingsInterface.tblData, where: SettingsInterface.colID + " = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Irgendetwas ging schief beim Löschen des Einstellungs-Eintrags: $err");
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
      print("Fehler beim Bestimmen der Anzahl getTabEntryCount " + err.toString());
    }
    if ( theList.length > 0 ) {
      return theList[0]['cnt'];
    } else {
      return -1;
    }
  }
}