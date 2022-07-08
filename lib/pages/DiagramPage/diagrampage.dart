import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import 'package:sysdiapulsgew/services/flutter_plot.dart';
import '../InfoPage/infopage.dart';
import '../SettingsPage/settingspage.dart';
import 'package:sysdiapulsgew/services/screenhelper.dart';

class diagramPage extends StatefulWidget {
  const diagramPage({Key? key}) : super(key: key);

  @override
  State<diagramPage> createState() => _diagramPageState();
}

bool _isLoading = true;
double _Faktor = 0.0;
int _selectedIndex = 0;
int anzTage = 14;
class _diagramPageState extends State<diagramPage> {

  List<Point> List_of_Points = [
    // const Point(21.30, 19.30),
    // const Point(3.0, 7.0),
    // const Point(8.0, 9.0),
    // const Point(11.0, 14.0),
    // const Point(18.0, 17.0),
    // const Point(7.0, 8.0),
    // const Point(4.0, 4.0),
    // const Point(6.0, 12.0),
  ];

  void _onItemTapped(int index) async {
    if ( mounted ) {
      switch (index) {
        case 0:                     // Start oder Home
          Navigator.pop(context);
          break;
        default:
          if (kDebugMode) {
            print("unbekannter index: " + index.toString());
          }
          break;
      }
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  ladeDaten() async {
    anzTage = await dbHelper.getDiagramDaysCount();
    List_of_Points = await dbHelper.getWertFuerDiagramm("Systole", -anzTage);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    ladeDaten();
  }
  @override
  Widget build(BuildContext context) {
    bool isLandscape = Screen.isLandscape(context);
    // bool isLargePhone = Screen.diagonal(context) > 720;
    // bool isNarrow = Screen.widthInches(context) < 3.5;
    bool isTablet = Screen.diagonalInches(context) >= 8.5; // war 7s
    isTablet ? _Faktor = 0.9 : _Faktor = 0.8;

    return Scaffold(
      // Header
      // ------
      appBar: AppBar(
        title: const Text('Diagramm'),
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
      ? const Center(child: CircularProgressIndicator())
      : List_of_Points.isEmpty
        ? Center(child: Text("keine Daten in den letzten $anzTage Tagen"))
        : SingleChildScrollView(
        child: Card(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text('Blutdruckwerte (Systole) der letzten $anzTage Tage'),
              ),
              Plot(
                height: MediaQuery.of(context).size.height * _Faktor,
                centered: false,
                data: List_of_Points,
                gridSize: const Offset(1.0, 1.0),
                style: PlotStyle(
                  pointRadius: 3.0,
                  outlineRadius: 1.0,
                  primary: Colors.white,
                  secondary: Colors.orange,
                  textStyle: const TextStyle(
                    fontSize: 11.0,
                    color: Colors.blueGrey,
                  ),
                  axis: Colors.blueGrey[600],
                  gridline: Colors.blueGrey[100],
                  trace: false,                       // Punkte nicht verbinden
                  traceClose: false,                  // nur wichtig, wenn trace: true
                  traceColor: Colors.orange,          // nur wichtig, wenn trcae: true
                  traceStokeWidth: 2.0,               // nur wichtig, wenn trace: true
                  axisStrokeWidth: 3.0,
                  showCoordinates: false,             // Punktkoordinaten nicht mit anzeigen
                  trailingZeros: false,               // Nachkommastellen nur, wenn nicht Null
                ),
                padding: const EdgeInsets.fromLTRB(50.0, 12.0, 12.0, 40.0),
                xTitle: 'Uhrzeit',
                // yTitle: 'Systole',
              ),
            ],
          ),
        ),
      ),

      // Footer
      // ------
      // bottomNavigationBar:
      // BottomNavigationBar(items: const <BottomNavigationBarItem>[
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.home),
      //     label: 'Home',
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
    );
  }
}
