import 'package:sysdiapulsgew/services/DataInterface.dart';
import 'package:sysdiapulsgew/services/SettingsInterface.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:flutter/foundation.dart';

class dbHelper {
  static const _databaseName = 'SysDiaPuls.db';
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
        ${DataInterface.colBemerkung} TEXT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${SettingsInterface.tblData}(
        ${SettingsInterface.colID} INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        ${SettingsInterface.colBezeichnung} TEXT NOT NULL,
        ${SettingsInterface.colTyp} TEXT NOT NULL,
        ${SettingsInterface.colWertInt} INTEGER NULL,
        ${SettingsInterface.colWertFloat} FLOAT NULL,
        ${SettingsInterface.colWertText} TEXT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      ''');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      _databaseName,
      version: _databaseVersion,
      onCreate: (sql.Database thisdb, int ver) async {
        await _onCreateDB(thisdb);
      },
    );
  }

  // Daten-Tabelle
  // -------------

  // neuer Eintrag
  static Future<int> createDataItem(DateTime Zeitpunkt, int Systole, int Diastole, int? Puls, double? Gewicht, String? Bemerkung) async {
    final db = await dbHelper.db();

    final data = {DataInterface.colZeitpunkt: Zeitpunkt,
                  DataInterface.colSystole: Systole,
                  DataInterface.colDiastole: Diastole,
                  DataInterface.colPuls: Puls,
                  DataInterface.colGewicht: Gewicht,
                  DataInterface.colBemerkung: Bemerkung};
    final id = await db.insert(DataInterface.tblData, data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // alle Einträge nach Zeitpunkt sortiert
  static Future<List<Map<String, dynamic>>> getDataItems() async {
    final db = await dbHelper.db();
    return db.query(DataInterface.tblData, orderBy: DataInterface.colZeitpunkt);
  }

  // der Eintrag mit der angegebenen ID
  static Future<List<Map<String, dynamic>>> getDataItem(int id) async {
    final db = await dbHelper.db();
    return db.query(DataInterface.tblData, where: DataInterface.colID + " = ?", whereArgs: [id], limit: 1);
  }

  // alle Einträge der letzten angegebenen Anzahl von Tagen
  static Future<List<Map<String, dynamic>>> getDataDays(int Tage) async {
    final db = await dbHelper.db();
    String SQL_Statement = "SELECT AVG(Systole) AS SysAVG";
    SQL_Statement += ", AVG(Diastole) AS DiaAVG";
    SQL_Statement += ", AVG(Puls) AS PulsAVG";
    SQL_Statement += " FROM tDaten";
    SQL_Statement += " WHERE Zeitpunkt BETWEEN ? AND ?";

    return db.rawQuery(SQL_Statement, ["Date('now')", "Date('now','-7 days')"]);
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
      DataInterface.colBemerkung: Bemerkung,
      'updatedAt': DateTime.now().toString()
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
      SettingsInterface.colWertText: Wert_TEXT,
      'updatedAt': DateTime.now().toString()
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
}