import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:table_calendar/table_calendar.dart';
import '../DetailPage/detailpage.dart';
import '../EntriesTablePage/entriestablepage.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../InfoPage/infopage.dart';
import '../../my-globals.dart' as globals;
import 'package:intl/intl.dart';
import '../EntriesPage/utils.dart';
import '../../services/myWidgets.dart' as myWidgets;

bool _isLoading = true;

class dailyEntriesTablePage extends StatefulWidget {
  const dailyEntriesTablePage({Key? key}) : super(key: key);

  @override
  State<dailyEntriesTablePage> createState() => _dailyEntriesTablePageState();
}

class _dailyEntriesTablePageState extends State<dailyEntriesTablePage> {
  // int _selectedIndex = 0;
  // void _onItemTapped(int index) async {
  //   if ( mounted ) {
  //     switch (index) {
  //       case 0:                     // Start oder Home
  //         Navigator.pop(context);
  //         break;
  //       case 1:                     // Liste der Einträge
  //         await Navigator.push(
  //           context,
  //           PageTransition(
  //             child: const EntriesTablePage(),
  //             alignment: Alignment.topCenter,
  //             type: PageTransitionType.leftToRightWithFade,
  //           ),
  //         );
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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _isLoading = false;
  }

  @override
  void dispose() {
    // _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getEventsForDays(days);
  }

  _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }

    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  _frageLoeschen(BuildContext context, int id) async {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        elevation: 5.0,
        // backgroundColor: Color.fromRGBO(255, 235, 235, 1),
        title: Container(
          // color: const Color.fromRGBO(255, 219, 219, 1),
          color: Theme.of(context).colorScheme.onError,
          child: Row(children: [
            // Icon(Icons.priority_high, color: Colors.red,),
            Expanded(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.center,
                child: Text(
                  "ACHTUNG:\nDiese Aktion kann\nnicht rückgängig\ngemacht werden!",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.8,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Icon(Icons.priority_high, color: Colors.red,),
          ]),
        ),
        content: const Text(
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
                  child: const Text(
                    'Nein',
                    textScaleFactor: 2.0,
                  ),
                ),
                ElevatedButton(
                  // style: ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(Colors.blue[100]),
                  // ),
                  onPressed: () async {
                    await _deleteItem(context, id);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Ja',
                    textScaleFactor: 2.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _deleteItem(BuildContext context, int id) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await dbHelper.deleteDataItem(id).then((value) async {
      await ladeEvents();
      await _onDaySelected(_selectedDay!, _focusedDay);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Eintrag gelöscht')),
    );
  }

  _editItem(BuildContext context, int id) async {
    globals.aktID = id;
    await Navigator.push(
      context,
      PageTransition(
        child: const DetailPage(),
        alignment: Alignment.topCenter,
        type: PageTransitionType.leftToRightWithFade,
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    });
    await ladeEvents();
    await _onDaySelected(_selectedDay!, _focusedDay);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _neuerEintrag(BuildContext context) async {
    globals.aktID = -1;
    int? Jahr = _selectedDay?.year;
    String sJahr = Jahr.toString();
    int? Monat = _selectedDay?.month;
    String sMonat = NumberFormat('00', 'de_DE').format(Monat);
    int? Tag = _selectedDay?.day;
    String sTag = NumberFormat('00', 'de_DE').format(Tag);
    int Stunde = DateTime.now().hour;
    String sStunde = NumberFormat('00', 'de_DE').format(Stunde);
    int Minute = DateTime.now().minute;
    String sMinute = NumberFormat('00', 'de_DE').format(Minute);
    DateTime neuZp = DateTime.parse('$sJahr-$sMonat-$sTag $sStunde:$sMinute');
    print(neuZp);
    globals.zeitpunktNeuerEintrag = neuZp.toString();
    print(neuZp);
    Navigator.pop(context, 'OK');
    await Navigator.push(
      context,
      PageTransition(
        child: const DetailPage(),
        alignment: Alignment.topCenter,
        type: PageTransitionType.leftToRightWithFade,
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    });
    await ladeEvents();
    await _onDaySelected(_selectedDay!, _focusedDay);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // Header
        // ------
        appBar: AppBar(
          backgroundColor: globals.CardColor,
          elevation: 4.0,
          title: const Text('Einträge'),
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
              icon: const Icon(Icons.article_outlined),
              onPressed: () {
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: const EntriesTablePage(),
                    alignment: Alignment.topCenter,
                    type: PageTransitionType.leftToRightWithFade,
                  ),
                );
              },
            ),
          ],
        ),

        // Body
        // ----
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : newTableCalendar(),

        // Floating Button
        // ---------------
        floatingActionButton: FloatingActionButton(
          backgroundColor: globals.CardColor,
          onPressed: () {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text(
                  'neuen Eintrag erfassen',
                ),
                content: const Text("Soll ein neuer Eintrag erfasst werden?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Nein');
                    },
                    child: const Text(
                      'Nein',
                      textScaleFactor: 2.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _neuerEintrag(context);
                    },
                    child: const Text(
                      'Ja',
                      textScaleFactor: 2.0,
                    ),
                  ),
                ],
              ),
            );
          },
          child: Icon(MdiIcons.plus),
          //backgroundColor: Colors.blue,
        ),

        // bottomNavigationBar:
        // BottomNavigationBar(items: <BottomNavigationBarItem>[
        //   const BottomNavigationBarItem(
        //     icon: Icon(Icons.home),
        //     label: 'Start',
        //   ),
        //   BottomNavigationBarItem(
        //     icon: badges.Badge(
        //       badgeColor: Theme.of(context).primaryColor,
        //       position: badges.BadgePosition.topEnd(),
        //       shape: badges.BadgeShape.square,
        //       borderRadius: BorderRadius.circular(8),
        //       padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
        //       badgeContent: Text(strAnzDSe,style: TextStyle(color: globals.BgColorNeutral),textScaleFactor: 0.8,),
        //       child: Icon(MdiIcons.calendarClock),
        //     ),
        //     label: 'Liste',
        //   ),
        // ],
        //   currentIndex: _selectedIndex,
        //   selectedItemColor: Theme.of(context).primaryColor,
        //   onTap: _onItemTapped,
        // ),
      ),
    );
  }

  late ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  Widget newTableCalendar() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        TableCalendar<Event>(
          rowHeight: 45.0,
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: globals.CardColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: globals.CardColor,
            ),
            weekendTextStyle: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            defaultTextStyle: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            todayTextStyle: const TextStyle(
              fontSize: 20.0,
            ),
            outsideTextStyle: const TextStyle(
              fontSize: 20.0,
              color: Colors.black26,
            ),
          ),
          locale: 'de_DE',
          weekendDays: const [DateTime.saturday, DateTime.sunday],
          startingDayOfWeek: StartingDayOfWeek.monday,
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          headerVisible: true,
          headerStyle: HeaderStyle(
            decoration: BoxDecoration(
              color: globals.CardColor,
            ),
            titleTextStyle: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
            titleCentered: true,
            formatButtonShowsNext: true,
            formatButtonVisible: false,
            // titleTextFormatter: (day,locale) => DateFormat.yM(locale).format(day),
          ),
          daysOfWeekHeight: 30.0,
          daysOfWeekStyle: DaysOfWeekStyle(
            decoration: BoxDecoration(
              color: globals.CardColor,
            ),
            weekendStyle: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
            weekdayStyle: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
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
        Container(
          color: Colors.black12,
          height: 3.0,
        ),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return CustomScrollView(
                slivers: <Widget>[
                  // ab hier werden die tatsächlichen Einträge aufgelistet
                  // -----------------------------------------------------
                  SliverFixedExtentList(
                      itemExtent:
                          globals.EntryHeight, // noch verbesserungsfähig!!!!!!
                      delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                        return InkWell(
                          onTap: () async {
                            await _editItem(context, value[index].getID());
                          },
                          onDoubleTap: () async {
                            await _frageLoeschen(context, value[index].getID());
                          },
                          child: myWidgets.datenZeile(
                            Zeitpunkt: value[index].getZeitpunkt(),
                            Systole: value[index].getSystole(),
                            Diastole: value[index].getDiastole(),
                            Puls: value[index].getPuls(),
                            Gewicht: value[index].getGewicht(),
                            Bemerkung: value[index].getBemerkung(),
                          ),
                        );
                      }, childCount: value.length)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // CalendarFormat _calendarFormat = CalendarFormat.month;
  // DateTime _focusedDay = DateTime.now();
  // DateTime? _selectedDay;

  // Widget _buildTableCalendar() {
  //   return TableCalendar(
  //     calendarFormat: CalendarFormat.twoWeeks,
  //     weekendDays: [DateTime.saturday, DateTime.sunday],
  //     pageJumpingEnabled: true,
  //     locale: 'de_DE',
  //     focusedDay: _focusedDay,
  //     firstDay: DateTime(2010, 1, 1 ),
  //     lastDay: DateTime(2030, 12, 31 ),
  //     startingDayOfWeek: StartingDayOfWeek.monday,
  //     calendarStyle: CalendarStyle(
  //
  //     ),
  //     onDaySelected: (selectedDay, focusedDay) {
  //       if (!isSameDay(_selectedDay, selectedDay)) {
  //         // Call `setState()` when updating the selected day
  //         setState(() {
  //           _selectedDay = selectedDay;
  //           _focusedDay = focusedDay;
  //         });
  //       }
  //     },
  //     selectedDayPredicate: (day) {
  //       // Use `selectedDayPredicate` to determine which day is currently selected.
  //       // If this returns true, then `day` will be marked as selected.
  //
  //       // Using `isSameDay` is recommended to disregard
  //       // the time-part of compared DateTime objects.
  //       return isSameDay(_selectedDay, day);
  //     },
  //     onFormatChanged: (format) {
  //       if (_calendarFormat != format) {
  //         // Call `setState()` when updating calendar format
  //         setState(() {
  //           _calendarFormat = format;
  //         });
  //       }
  //     },
  //     onPageChanged: (focusedDay) {
  //       // No need to call `setState()` here
  //       _focusedDay = focusedDay;
  //     },
  //   );
  // }
}

// class _CalendarHeader extends StatelessWidget {
//   final DateTime focusedDay;
//   final VoidCallback onLeftArrowTap;
//   final VoidCallback onRightArrowTap;
//   final VoidCallback onTodayButtonTap;
//   final VoidCallback onClearButtonTap;
//   final bool clearButtonVisible;
//
//   const _CalendarHeader({
//     Key? key,
//     required this.focusedDay,
//     required this.onLeftArrowTap,
//     required this.onRightArrowTap,
//     required this.onTodayButtonTap,
//     required this.onClearButtonTap,
//     required this.clearButtonVisible,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final headerText = DateFormat.yMMM().format(focusedDay);
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           const SizedBox(width: 16.0),
//           SizedBox(
//             width: 120.0,
//             child: Text(
//               headerText,
//               style: TextStyle(fontSize: 26.0),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.calendar_today, size: 20.0),
//             visualDensity: VisualDensity.compact,
//             onPressed: onTodayButtonTap,
//           ),
//           if (clearButtonVisible)
//             IconButton(
//               icon: Icon(Icons.clear, size: 20.0),
//               visualDensity: VisualDensity.compact,
//               onPressed: onClearButtonTap,
//             ),
//           const Spacer(),
//           IconButton(
//             icon: Icon(Icons.chevron_left),
//             onPressed: onLeftArrowTap,
//           ),
//           IconButton(
//             icon: Icon(Icons.chevron_right),
//             onPressed: onRightArrowTap,
//           ),
//         ],
//       ),
//     );
//   }
// }
