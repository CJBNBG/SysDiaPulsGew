class SettingsInterface {
  static const tblData = 'tSettings';
  static const colID = 'pid';
  static const colBezeichnung = 'Bezeichnung';
  static const colTyp = 'Typ';
  static const colWertInt = 'Wert_INT';
  static const colWertFloat = 'Wert_FLOAT';
  static const colWertText = 'Wert_TEXT';

  int ID = 0;
  String Bezeichnung = '';
  String Typ = '';
  int Wert_INT = 0;
  double Wert_FLOAT = 0.0;
  String Wert_TEXT = '';

  SettingsInterface(
    {
      required this.ID,
      required this.Bezeichnung,
      required this.Typ,
      required this.Wert_INT,
      required this.Wert_FLOAT,
      required this.Wert_TEXT
    }
  );

  SettingsInterface.fromMap(Map<String, dynamic> map) {
    this.ID = map[colID];
    this.Bezeichnung = map[colBezeichnung];
    this.Typ = map[colTyp];
    this.Wert_INT = map[colWertInt];
    this.Wert_FLOAT = map[colWertFloat];
    this.Wert_TEXT = map[colWertText];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colBezeichnung: Bezeichnung, colTyp: Typ, colWertInt: Wert_INT, colWertFloat: Wert_FLOAT, colWertText: Wert_TEXT};
    if (ID != null) {
      map[colID] = ID;
    }
    return map;
  }
}