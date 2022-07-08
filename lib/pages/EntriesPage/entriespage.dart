import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sysdiapulsgew/myUpdateProvider.dart';
import 'package:sysdiapulsgew/services/screenhelper.dart';
import '../../services/myWidgets.dart' as myWidgets;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../my-globals.dart' as globals;
import '../DetailPage/detailpage.dart';
import '../InfoPage/infopage.dart';
import '../SettingsPage/settingspage.dart';
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

// ----------------------------------------------------------------------------------------
// Funktionen/Module, die in der ganzen Datei verfügbar sein müssen
// ----------------------------------------------------------------------------------------
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

  _ladeAlleDaten() async {
    setState(() {
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
        body: Column(
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
                            myProvider.updateAll();
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
                            myProvider.updateAll();
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
                      myProvider.updateAll();
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
      ),
    );
  }
}
