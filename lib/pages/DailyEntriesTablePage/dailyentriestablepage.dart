import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:table_calendar/table_calendar.dart';
import '../EntriesTablePage/entriestablepage.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../InfoPage/infopage.dart';
import '../SettingsPage/settingspage.dart';
import '../../my-globals.dart' as globals;
import 'package:intl/intl.dart';
import '../EntriesPage/utils.dart';

bool _isLoading = true;

class dailyEntriesTablePage extends StatefulWidget {
  const dailyEntriesTablePage({Key? key}) : super(key: key);

  @override
  State<dailyEntriesTablePage> createState() => _dailyEntriesTablePageState();
}

class _dailyEntriesTablePageState extends State<dailyEntriesTablePage> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) async {
    if ( mounted ) {
      switch (index) {
        case 0:                     // Start oder Home
          Navigator.pop(context);
          break;
        case 1:                     // Liste der Einträge
          await Navigator.push(
            context,
            PageTransition(
              child: const EntriesTablePage(),
              alignment: Alignment.topCenter,
              type: PageTransitionType.leftToRightWithFade,
            ),
          );
          break;
        default:
          print("unbekannter index: " + index.toString());
          break;
      }
      setState(() {
        _selectedIndex = 0;
      });
    }
  }
  String strAnzDSe = "?";

  void _ladeDaten() async {
    try {
      final d1 = await dbHelper.getEntryCount();
      if ( mounted ) {
        setState(() {
          if (d1 != null) {
            strAnzDSe = d1.toString();
          } else {
            strAnzDSe = "0";
          }
        });
      }
    } on Error catch( _, e ) {
      print("Fehler in _ladeDaten(): $e");
    }
    if ( mounted ) setState(() {
      _isLoading = false;
    });
  }

  void _initDaten() async {
    _ladeDaten();
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    // _selectedDays.add(_focusedDay.value);
    // _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
    _initDaten();
  }

  @override
  void dispose() {
    // _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  // bool get canClearSelection =>
  //     _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  List<Event> _getEventsForDay(DateTime day) {
    setState() {
      _isLoading = false;
    }
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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // setState(() {
    //   if (_selectedDays.contains(selectedDay)) {
    //     _selectedDays.remove(selectedDay);
    //   } else {
    //     _selectedDays.add(selectedDay);
    //   }
    //
    //   _focusedDay.value = focusedDay;
    //   _rangeStart = null;
    //   _rangeEnd = null;
    //   _rangeSelectionMode = RangeSelectionMode.toggledOff;
    // });
    //
    // _selectedEvents.value = _getEventsForDays(_selectedDays);
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    // setState(() {
    //   _focusedDay.value = focusedDay;
    //   _rangeStart = start;
    //   _rangeEnd = end;
    //   _selectedDays.clear();
    //   _rangeSelectionMode = RangeSelectionMode.toggledOn;
    // });
    //
    // if (start != null && end != null) {
    //   _selectedEvents.value = _getEventsForRange(start, end);
    // } else if (start != null) {
    //   _selectedEvents.value = _getEventsForDay(start);
    // } else if (end != null) {
    //   _selectedEvents.value = _getEventsForDay(end);
    // }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Header
      // ------
      appBar: AppBar(
        title: Text( 'Einträge'),
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
                  type: PageTransitionType.leftToRightWithFade,),
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
                  type: PageTransitionType.leftToRightWithFade,),
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

      bottomNavigationBar:
      BottomNavigationBar(items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Start',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            child: Icon(MdiIcons.calendarClock),
            badgeColor: Theme.of(context).primaryColor,
            position: BadgePosition.topEnd(),
            shape: BadgeShape.square,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
            badgeContent: Text(strAnzDSe,style: TextStyle(color: globals.BgColorNeutral),textScaleFactor: 0.8,),
          ),
          label: 'Liste',
        ),
      ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }

  // late final PageController _pageController;
  late final ValueNotifier<List<Event>> _selectedEvents;
  // final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
  //   equals: isSameDay,
  //   hashCode: getHashCode,
  // );
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  Widget newTableCalendar() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // ValueListenableBuilder<DateTime>(
        //   valueListenable: _focusedDay,
        //   builder: (context, value, _) {
        //     return _CalendarHeader(
        //       focusedDay: value,
        //       clearButtonVisible: canClearSelection,
        //       onTodayButtonTap: () {
        //         setState(() => _focusedDay.value = DateTime.now());
        //       },
        //       onClearButtonTap: () {
        //         setState(() {
        //           _rangeStart = null;
        //           _rangeEnd = null;
        //           _selectedDays.clear();
        //           _selectedEvents.value = [];
        //         });
        //       },
        //       onLeftArrowTap: () {
        //         _pageController.previousPage(
        //           duration: Duration(milliseconds: 300),
        //           curve: Curves.easeOut,
        //         );
        //       },
        //       onRightArrowTap: () {
        //         _pageController.nextPage(
        //           duration: Duration(milliseconds: 300),
        //           curve: Curves.easeOut,
        //         );
        //       },
        //     );
        //   },
        // ),
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
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          headerVisible: true,
          headerStyle: HeaderStyle(
            formatButtonShowsNext: true,
            formatButtonVisible: false,
            // titleTextFormatter: (day,locale) => DateFormat.yM(locale).format(day),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
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
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () => print('${value[index]}'),
                      title: Text('${value[index]}'),
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

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onClearButtonTap,
    required this.clearButtonVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: TextStyle(fontSize: 26.0),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          if (clearButtonVisible)
            IconButton(
              icon: Icon(Icons.clear, size: 20.0),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}