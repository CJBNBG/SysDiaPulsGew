class DataInterface {
  static const tblData = 'tDaten';
  static const colID = 'pid';
  static const colZeitpunkt = 'Zeitpunkt';
  static const colSystole = 'Systole';
  static const colDiastole = 'Diastole';
  static const colPuls = 'Puls';
  static const colGewicht = 'Gewicht';
  static const colBemerkung = 'Bemerkung';

  int ID = 0;
  DateTime Zeitpunkt = DateTime(2021,1,1);
  int Systole = 0;
  int Diastole = 0;
  int Puls = 0;
  double Gewicht = 0.0;
  String Bemerkung = '';
  DataInterface(
    {
      required this.ID,
      required this.Zeitpunkt,
      required this.Systole,
      required this.Diastole,
      required this.Puls,
      required this.Gewicht,
      required this.Bemerkung
    }
  );

  DataInterface.fromMap(Map<String, dynamic> map) {
    this.ID = map[colID];
    this.Zeitpunkt = map[colZeitpunkt];
    this.Systole = map[colSystole];
    this.Diastole = map[colDiastole];
    this.Puls = map[colPuls];
    this.Gewicht = map[colGewicht];
    this.Bemerkung = map[colBemerkung];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colSystole: Systole, colDiastole: Diastole, colPuls: Puls, colGewicht: Gewicht, colBemerkung: Bemerkung};
    if (ID != null) {
      map[colID] = ID;
    }
    return map;
  }
}