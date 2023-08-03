// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';

import '../../services/DataInterface.dart';

/// Example event class.
class Event {
  int _ID;
  String _Zeitpunkt;
  int _Systole;
  int _Diastole;
  int _Puls;
  double? _Gewicht;
  String _Bemerkung;

  Event(this._ID, this._Zeitpunkt, this._Systole, this._Diastole, this._Puls, this._Gewicht, this._Bemerkung);

  int getID() => _ID;
  String getZeitpunkt() => _Zeitpunkt;
  int getSystole() => _Systole;
  int getDiastole() => _Diastole;
  int getPuls() {
    if ( _Puls.toString().isEmpty ) return 0;
    else return _Puls;
  }
  double? getGewicht() {
    if ( _Gewicht.toString().isEmpty ) return 0.0;
    else return _Gewicht;
  }
  String getBemerkung() => _Bemerkung;

  @override
  String toString() {
    String Jahr = _Zeitpunkt.substring(0, 4);
    String Monat = _Zeitpunkt.substring(5, 7);
    String Tag = _Zeitpunkt.substring(8, 10);
    String Stunde = _Zeitpunkt.substring(11, 13);
    String Minute = _Zeitpunkt.substring(14, 16);
    return '$Tag.$Monat.$Jahr $Stunde:$Minute\n$_Systole:$_Diastole $_Puls ' + getGewicht().toString() + '\n$_Bemerkung';
  }
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
var kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(kEventSource);

Map<DateTime,List<Event>> kEventSource = {};

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year-1, 1, 1);
final kLastDay = DateTime(kToday.year+1, 12, 31);

int Limit = -1;
int LimitFromSettings = 25;
int iAnzEntries = 0;
List<Map<String, dynamic>>alleEintraege = [];
List<Map<String, dynamic>>alleTage = [];
List<Map<String, dynamic>>alleEintraegeAnTag = [];

ladeEintraege() async {
  try {
    LimitFromSettings = await dbHelper.getTabEntryCount();
    iAnzEntries = (await dbHelper.getEntryCount())!;
    if ( iAnzEntries > 0 ) {
      if ( iAnzEntries < LimitFromSettings ) {
        Limit = iAnzEntries;
      } else {
        Limit = LimitFromSettings;
      }
    } else {
      Limit = 0;
    }
    // _iAnzEntries = (await dbHelper.getEntryCount())!;
    alleEintraege = await dbHelper.getDataItems(Limit);
    if (kDebugMode) {
      print("${alleEintraege.length} Einträge geladen");
    }
  } on Error catch( _, e ) {
    print("Fehler in _ladeDaten(): $e");
  }
}
ladeEvents() async {
  try {
    kEventSource = {};
    alleTage = await dbHelper.getOnlyDataDays();
    if ( alleTage.isNotEmpty ) {
      int tag, monat, jahr;
      await Future.forEach( alleTage,
              (element) async {
            if ( element != null ) {
              jahr = int.parse(element.toString().substring(9, 14));
              monat = int.parse(element.toString().substring(15, 17));
              tag = int.parse(element.toString().substring(18, 20));
              alleEintraegeAnTag = await dbHelper.getDataItemsForDay(DateTime(jahr,monat,tag,0,0,0));
              kEventSource.addAll({
                DateTime(jahr,monat,tag):
                List.generate(
                  alleEintraegeAnTag.length, (index) => Event(
                    alleEintraegeAnTag[index][DataInterface.colID],
                    alleEintraegeAnTag[index][DataInterface.colZeitpunkt],
                    alleEintraegeAnTag[index][DataInterface.colSystole],
                    alleEintraegeAnTag[index][DataInterface.colDiastole],
                    alleEintraegeAnTag[index][DataInterface.colPuls].toString().isNotEmpty ? alleEintraegeAnTag[index][DataInterface.colPuls] : 0,
                    alleEintraegeAnTag[index][DataInterface.colGewicht].toString().isNotEmpty? alleEintraegeAnTag[index][DataInterface.colGewicht] : 0.0,
                    alleEintraegeAnTag[index][DataInterface.colBemerkung],
                  )
                )
              });
            }
            return null;
          }
      );
    }
    kEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(kEventSource);
    if (kDebugMode) {
      print("${kEvents.length} Events geladen");
    }
  } on Error catch( _, e ) {
    if (kDebugMode) {
      print("Fehler in _ladeDaten(): $e");
    }
  }
}
