import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sysdiapulsgew/myUpdateProvider.dart';
import 'package:sysdiapulsgew/services/DataInterface.dart';
import 'package:sysdiapulsgew/services/screenhelper.dart';
import '../../services/myWidgets.dart' as myWidgets;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../my-globals.dart' as globals;
import '../DetailPage/detailpage.dart';
import '../InfoPage/infopage.dart';
import '../SettingsPage/settingspage.dart';
import '../StatistikPage/statistikpage.dart';
import 'utils.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';

// ----------------------------------------------------------------------------------------
// Variablen, die in der ganzen Datei verfügbar sein müssen
// ----------------------------------------------------------------------------------------
bool _isLoadingTable = true;
bool _isLoadingCalendar = true;
late ValueNotifier<List<Event>> _selectedEvents;
DateTime _focusedDay = DateTime.now();
DateTime? _selectedDay;
CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
DateTime? _rangeStart;
DateTime? _rangeEnd;

double _scaleFactor = 1.0;
int _Bemlen = 1;
double _BreiteZeitpunkt = 1.0;
double _hoeheUberschrift = 1.0;
// ----------------------------------------------------------------------------------------
// Funktionen/Module, die in der ganzen Datei verfügbar sein müssen
// ----------------------------------------------------------------------------------------
_frageLoeschen(BuildContext context, int index) async {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      elevation: 5.0,
      // backgroundColor: Color.fromRGBO(255, 235, 235, 1),
      title: Container(
        color: Color.fromRGBO(255, 219, 219, 1),
        child: Row(children: [
          // Icon(Icons.priority_high, color: Colors.red,),
          Container(
            child: const Expanded(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                child: Text(
                  "ACHTUNG:\nDiese Aktion kann\nnicht rückgängig\ngemacht werden!",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  textScaleFactor: 2.0,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          // Icon(Icons.priority_high, color: Colors.red,),
        ]),
      ),
      content: Text(
        "Möchten Sie diesen Eintrag wirklich löschen?",
        textAlign: TextAlign.center,
        softWrap: true,
        textScaleFactor: 2.0,
      ),
      actions: <Widget>[
        // SizedBox(width: 20.0,),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  // style: ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(Colors.green[100]),/8/8+9
                  // ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Nein')),
              ElevatedButton(
                // style: ButtonStyle(
                //   backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
                // ),
                onPressed: () async {
                  await _deleteItem(context, index);
                  Navigator.pop(context);
                },
                child: const Text('Ja'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

_deleteItem(BuildContext context, int ndx) async {
  int id = alleEintraege[ndx][DataInterface.colID];
  if (id != null) {
    await dbHelper.deleteDataItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Eintrag gelöscht')),
    );
    // setState(() {
    //   _ladeDaten();
    //   globals.updAVG_needed = true;
    // });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fehler beim löschen ($id)')),
    );
  }
}

_editItem(BuildContext context, int ndx) async {
  int id = alleEintraege[ndx][DataInterface.colID];
  if (id == null) {
    id = -1;
  }
  globals.aktID = id;
  await Navigator.push(
    context,
    PageTransition(
      child: DetailPage(),
      alignment: Alignment.topCenter,
      type: PageTransitionType.leftToRightWithFade,
    ),
  );
}

_neuerEintrag(BuildContext context) async {
  globals.aktID = -1;
  Navigator.pop(context, 'OK');
  await Navigator.push(
    context,
    PageTransition(
      child: DetailPage(),
      alignment: Alignment.topCenter,
      type: PageTransitionType.leftToRightWithFade,
    ),
  );
}

List<Event> _getEventsForDay(DateTime day) {
  // List<Map<String, dynamic>> result = dbHelper.getDataItemsForDay(day);
  return kEvents[day] ?? [];
}

String dasDatum(String Zeitpunkt) {
  if (Zeitpunkt.length == 0)
    return "kein Datum";
  else
    return Zeitpunkt.substring(8, 10) + "." + Zeitpunkt.substring(5, 7) + "." + Zeitpunkt.substring(0, 4);
}

String dieUhrzeit(String Zeitpunkt) {
  if (Zeitpunkt.length == 0)
    return "keine Uhrzeit";
  else
    return Zeitpunkt.substring(11, 16);
}

// ----------------------------------------------------------------------------------------
// ab hier jetzt die Seiten/Widgets
// ----------------------------------------------------------------------------------------
class EntriesPage extends StatefulWidget {
  const EntriesPage({Key? key}) : super(key: key);

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  final PageController _controller = PageController();

  // int _selectedIndex = 0;
  List<Widget> _list = [
    // 1. Seite: Tabellendarstellung
    // -----------------------------
    SliderBox(
      child: _entriesTable(),
    ),
    // 2. Seite: Kalenderdarstellung
    // -----------------------------
    SliderBox(
      child: _entriesCalendar(),
    ),
  ];

  // void _onItemTapped(int index) async {
  //   if ( mounted ) {
  //     switch (index) {
  //       case 0:                     // Start oder Home
  //         Navigator.pop(context);
  //         break;
  //       case 1:                     // Liste der Einträge
  //         break;
  //       default:
  //         print("unbekannter index: " + index.toString());
  //         break;
  //     }
  //     setState(() {
  //       _selectedIndex = 0;
  //     });
  //   }
  // }
  // List<Event> _getEventsForDay(DateTime day) {
  //   // List<Map<String, dynamic>> result = dbHelper.getDataItemsForDay(day);
  //   return kEvents[day] ?? [];
  // }

  // List<Event> _getEventsForDays(Iterable<DateTime> days) {
  //   return [
  //     for (final d in days) ..._getEventsForDay(d),
  //   ];
  // }

  // List<Event> _getEventsForRange(DateTime start, DateTime end) {
  //   final days = daysInRange(start, end);
  //   return _getEventsForDays(days);
  // }
  // Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
  //   if (!isSameDay(_selectedDay, selectedDay)) {
  //     setState(() {
  //       _selectedDay = selectedDay;
  //       _focusedDay = focusedDay;
  //       _rangeStart = null; // Important to clean those
  //       _rangeEnd = null;
  //       _rangeSelectionMode = RangeSelectionMode.toggledOff;
  //     });
  //
  //     _selectedEvents.value = await _getEventsForDay(selectedDay);
  //   }
  // }

  // void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
  //   setState(() {
  //     _selectedDay = null;
  //     _focusedDay = focusedDay;
  //     _rangeStart = start;
  //     _rangeEnd = end;
  //     _rangeSelectionMode = RangeSelectionMode.toggledOn;
  //   });
  // }

  _ladeAlleDaten() async {
    // await _ladeEvents();
    // await _ladeEintraege();
    setState(() {
      // _isLoadingTable = false;
      // _isLoadingCalendar = false;
      _selectedDay = _focusedDay;
      _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    });
  }

  @override
  void initState() {
    super.initState();
    _ladeAlleDaten();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = Screen.isLandscape(context);
    // bool isLargePhone = Screen.diagonal(context) > 720;
    // bool isNarrow = Screen.widthInches(context) < 3.5;
    bool isTablet = Screen.diagonalInches(context) >= 8.5; // war 7s
    _scaleFactor = isTablet ? globals.scaleFactorTablet : globals.scaleFactorPhone;
    _Bemlen = isTablet ? globals.BemlenTablet : globals.BemlenPhone;
    _BreiteZeitpunkt = MediaQuery.of(context).size.width / 3.0;
    _hoeheUberschrift = isTablet ? 92.0 : 70.0;
    PageIndicatorContainer container = PageIndicatorContainer(
      child: PageView(
        controller: _controller,
        children: _list,
      ),
      length: _list.length,
      padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
      indicatorSpace: 10,
      indicatorColor: Colors.grey,
      indicatorSelectorColor: Colors.blue,
    );
    var myProvider = Provider.of<myUpdateProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Einträge"),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: () {
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const InfoPage(),
                    alignment: Alignment.topCenter,
                    type: PageTransitionType.leftToRightWithFade,
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_sharp),
              onPressed: () {
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const SettingsPage(),
                    alignment: Alignment.topCenter,
                    type: PageTransitionType.leftToRightWithFade,
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(color: Colors.grey[100], height: double.infinity),
            Container(color: globals.BgColorNeutral, child: container, margin: const EdgeInsets.all(0.0)),
          ],
        ),
        // Floating Button
        // ---------------
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Neuen Eintrag erfassen'),
                content: Text("Soll ein neuer Eintrag erfasst werden?"),
                actions: <Widget>[
                  TextButton(onPressed: () => Navigator.pop(context, 'Nein'), child: const Text('Nein')),
                  TextButton(
                    onPressed: () async {
                      await _neuerEintrag(context);
                      _isLoadingTable = true;
                      _isLoadingCalendar = true;
                      myProvider.increment();
                      _selectedDay = _focusedDay;
                      _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
                      setState(() {
                        globals.updAVG_needed = true;
                        _isLoadingTable = false;
                        _isLoadingCalendar = false;
                      });
                    },
                    child: const Text('Ja'),
                  ),
                ],
              ),
            );
          },
          child: Icon(MdiIcons.plus),
          //backgroundColor: Colors.blue,
        ),
        // bottomNavigationBar: BottomNavigationBar(items: const <BottomNavigationBarItem>[
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.home),
        //     label: 'Start',
        //   ),
        //   BottomNavigationBarItem(
        //     icon: Text(''),
        //     label: '',
        //   ),
        // ],
        //   currentIndex: _selectedIndex,
        //   selectedItemColor: Theme.of(context).primaryColor,
        //   onTap: _onItemTapped,
        // ),
      ),
    );
  }
}

// -------------------------------------------------------------------------------------------------------
// Tabellendarstellung
// -------------------------------------------------------------------------------------------------------
class _entriesTable extends StatefulWidget {
  const _entriesTable({Key? key}) : super(key: key);

  @override
  State<_entriesTable> createState() => _entriesTableState();
}

class _entriesTableState extends State<_entriesTable> {
  void _initDaten() async {
    // _selectedDay = _focusedDay;
    // _selectedEvents = ValueNotifier(await _getEventsForDay(_selectedDay!));
    _isLoadingTable = false;
  }

  @override
  void initState() {
    super.initState();
    _initDaten();
  }

  @override
  Widget build(BuildContext context) {
    var myProvider = Provider.of<myUpdateProvider>(context, listen: false);

    return Column(
      children: [
        Flexible(
          flex: 1,
          child: Container(
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            // alignment: Alignment.center,
            color: Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Headerzeile
                // -----------------------------------------------------
                Flexible(
                    flex: 1,
                    child: myWidgets.myListRowWidgetOneLine(
                        isHeader: true,
                        Titel1: "Zeitpunkt",
                        Farbe1: Colors.grey,
                        Farbe2: Colors.grey[500],
                        Breite: _BreiteZeitpunkt,
                        ScaleFactor: _scaleFactor,
                        alignment: Alignment.center)),
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            myWidgets.myListRowWidgetTwoLines(
                                isHeader: true,
                                Titel1: 'Systole',
                                Titel2: '(mmHg)',
                                Farbe1: Colors.grey,
                                Farbe2: Colors.grey[500],
                                Breite: _BreiteZeitpunkt / 2.0,
                                ScaleFactor: _scaleFactor),
                            myWidgets.myListRowWidgetTwoLines(
                                isHeader: true,
                                Titel1: 'Diastole',
                                Titel2: '(mmHg)',
                                Farbe1: Colors.grey,
                                Farbe2: Colors.grey[500],
                                Breite: _BreiteZeitpunkt / 2.0,
                                ScaleFactor: _scaleFactor),
                            myWidgets.myListRowWidgetTwoLines(
                                isHeader: true,
                                Titel1: 'Puls',
                                Titel2: '(bpm)',
                                Farbe1: Colors.grey,
                                Farbe2: Colors.grey[500],
                                Breite: _BreiteZeitpunkt / 2.0,
                                ScaleFactor: _scaleFactor),
                            myWidgets.myListRowWidgetTwoLines(
                                isHeader: true,
                                Titel1: 'Gewicht',
                                Titel2: '(kg)',
                                Farbe1: Colors.grey,
                                Farbe2: Colors.grey[500],
                                Breite: _BreiteZeitpunkt / 2.0,
                                ScaleFactor: _scaleFactor),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: myWidgets.myListRowWidgetOneLine(
                          isHeader: true,
                          Titel1: 'Bemerkung',
                          Farbe1: Colors.grey,
                          Farbe2: Colors.grey[500],
                          Breite: _BreiteZeitpunkt * 2.0,
                          ScaleFactor: _scaleFactor,
                          alignment: Alignment.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 6,
          child: _isLoadingTable
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : CustomScrollView(
                  slivers: <Widget>[
                    // ab hier werden die tatsächlichen Einträge aufgelistet
                    // -----------------------------------------------------
                    SliverFixedExtentList(
                        itemExtent: globals.EntryHeight, // noch verbesserungsfähig!!!!!!
                        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                          return InkWell(
                            onTap: () async {
                              await _editItem(context, index);
                              _isLoadingTable = true;
                              _selectedDay = _focusedDay;
                              _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
                              myProvider.increment();
                              setState(() {
                                _isLoadingTable = false;
                                globals.updAVG_needed = true;
                              });
                            },
                            onDoubleTap: () async {
                              await _frageLoeschen(context, index);
                              _isLoadingTable = true;
                              _selectedDay = _focusedDay;
                              _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
                              myProvider.increment();
                              setState(() {
                                globals.updAVG_needed = true;
                                _isLoadingTable = false;
                              });
                            },
                            child: myWidgets.datenZeile(
                              Zeitpunkt: alleEintraege[index]['Zeitpunkt'],
                              Systole: alleEintraege[index]['Systole'],
                              Diastole: alleEintraege[index]['Diastole'],
                              Puls: alleEintraege[index]['Puls'],
                              Gewicht: alleEintraege[index]['Gewicht'],
                              Bemerkung: alleEintraege[index]['Bemerkung'],
                            ),
                          );
                        }, childCount: alleEintraege.length)),
                  ],
                ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------------------------------------------
// Kalenderdarstellung
// -------------------------------------------------------------------------------------------------------
class _entriesCalendar extends StatefulWidget {
  const _entriesCalendar({Key? key}) : super(key: key);

  @override
  State<_entriesCalendar> createState() => _entriesCalendarState();
}

class _entriesCalendarState extends State<_entriesCalendar> {
  // List<Event> _getEventsForDay(DateTime day) {
  //   // List<Map<String, dynamic>> result = dbHelper.getDataItemsForDay(day);
  //   return kEvents[day] ?? [];
  // }

  // List<Event> _getEventsForDays(Iterable<DateTime> days) {
  //   return [
  //     for (final d in days) ..._getEventsForDay(d),
  //   ];
  // }

  // List<Event> _getEventsForRange(DateTime start, DateTime end) {
  //   final days = daysInRange(start, end);
  //   return _getEventsForDays(days);
  // }
  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = await _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  _frageLoeschenTabelle(BuildContext context, int index) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        elevation: 5.0,
        // backgroundColor: Color.fromRGBO(255, 235, 235, 1),
        title: Container(
          color: Color.fromRGBO(255, 219, 219, 1),
          child: Row(children: [
            // Icon(Icons.priority_high, color: Colors.red,),
            Container(
              child: const Expanded(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                  child: Text(
                    "ACHTUNG:\nDiese Aktion kann\nnicht rückgängig\ngemacht werden!",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    textScaleFactor: 2.0,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
            // Icon(Icons.priority_high, color: Colors.red,),
          ]),
        ),
        content: Text(
          "Möchten Sie diesen Eintrag wirklich löschen?",
          textAlign: TextAlign.center,
          softWrap: true,
          textScaleFactor: 2.0,
        ),
        actions: <Widget>[
          // SizedBox(width: 20.0,),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  // style: ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(Colors.green[100]),/8/8+9
                  // ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Nein')),
                ElevatedButton(
                  // style: ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
                  // ),
                  onPressed: () async {
                    await _deleteItemTabelle(context, index);
                    Navigator.pop(context);
                  },
                  child: const Text('Ja'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _deleteItemTabelle(BuildContext context, int ndx) async {
    _selectedEvents.value = await _getEventsForDay(_selectedDay!);
    if ( _selectedEvents != null ) {
      int id = _selectedEvents.value[ndx].getID();
      if (id != null) {
        await dbHelper.deleteDataItem(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eintrag gelöscht', style: TextStyle(backgroundColor: Colors.grey))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim löschen ($id)', style: TextStyle(backgroundColor: Colors.red))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eintrag könnte nicht gefunden werden', style: TextStyle(backgroundColor: Colors.red),)),
      );
    }
  }

  _editItemTabelle(BuildContext context, int ndx) async {
    _selectedEvents.value = await _getEventsForDay(_selectedDay!);
    int id = _selectedEvents.value[ndx].getID();
    if (id == null) {
      id = -1;
    }
    globals.aktID = id;
    await Navigator.push(
      context,
      PageTransition(
        child: DetailPage(),
        alignment: Alignment.topCenter,
        type: PageTransitionType.leftToRightWithFade,
      ),
    );
  }

  void _initDaten() async {
    // _selectedDay = _focusedDay;
    // _selectedEvents = ValueNotifier(await _getEventsForDay(_selectedDay!));
    _isLoadingCalendar = false;
  }

  @override
  void initState() {
    super.initState();
    _initDaten();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = Screen.isLandscape(context);
    // bool isLargePhone = Screen.diagonal(context) > 720;
    // bool isNarrow = Screen.widthInches(context) < 3.5;
    bool isTablet = Screen.diagonalInches(context) >= 8.5; // war 7s
    _calendarFormat = isTablet ? CalendarFormat.month : CalendarFormat.twoWeeks;
    var myProvider = Provider.of<myUpdateProvider>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        TableCalendar<Event>(
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
            ),
            weekendTextStyle: TextStyle(color: Colors.black45),
          ),
          locale: 'de_DE',
          weekendDays: [DateTime.saturday, DateTime.sunday],
          startingDayOfWeek: StartingDayOfWeek.monday,
          firstDay: globals.calendarStart,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          headerVisible: true,
          headerStyle: const HeaderStyle(
            formatButtonShowsNext: false,
            formatButtonVisible: false,
            titleCentered: true,
            headerMargin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            headerPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
            // titleTextFormatter: (day,locale) => DateFormat.yM(locale).format(day),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekendStyle: TextStyle(color: Colors.black45),
          ),
          selectedDayPredicate: (day) {
            // getEventsFromDBForDay(day);
            return isSameDay(_selectedDay, day);
          },
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getEventsForDay,
          //   holidayPredicate: (day) {
          //     // Every 20th day of the month will be treated as a holiday
          //     return day.day == 20;
          //   },
          onDaySelected: _onDaySelected,
          onRangeSelected: _onRangeSelected,
          // onCalendarCreated: (controller) => _pageController = controller,
          onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() => _calendarFormat = format);
            }
          },
        ),
        SizedBox(
          height: 5.0,
          child: Container(
            color: Colors.grey[300],
          ),
        ),
        Expanded(
          child: _isLoadingCalendar
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: globals.EntryHeight,
                          // color: Colors.grey[300],
                          child: InkWell(
                            onTap: () async {
                              await _editItemTabelle(context, index);
                              _isLoadingCalendar = true;
                              _selectedDay = _focusedDay;
                              _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
                              myProvider.increment();
                              setState(() {
                                _isLoadingCalendar = false;
                                globals.updAVG_needed = true;
                              });
                            },
                            onDoubleTap: () async {
                              await _frageLoeschenTabelle(context, index);
                              _isLoadingCalendar = true;
                              _selectedDay = _focusedDay;
                              _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
                              myProvider.increment();
                              setState(() {
                                _isLoadingCalendar = false;
                                globals.updAVG_needed = true;
                              });
                            },
                            child: myWidgets.datenZeile(
                              Zeitpunkt: value[index].getZeitpunkt(),
                              Systole: value[index].getSystole(),
                              Diastole: value[index].getDiastole(),
                              Puls: value[index].getPuls(),
                              Gewicht: value[index].getGewicht(),
                              Bemerkung: "${value[index].getBemerkung()}",
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
