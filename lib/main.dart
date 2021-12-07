import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sysdiapulsgew/pages/InfoPage/infopage.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import 'my-globals.dart' as globals;
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SysDiaPulsGew',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const MyHomePage(title: 'SysDiaPulsGew'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/infopage':
            return PageTransition(
              child: InfoPage(),
              type: PageTransitionType.fade,
              settings: settings,
              reverseDuration: const Duration(seconds: 3),
            );
            //break;
          default:
            return null;
        }
      },
    );

  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String strSysAVG = '---';
  String strDiaAVG = '---';
  String strPulsAVG = '---';
  String strAnzahl = '---';
  // List<Map<String, dynamic>> _datamap = [
  //   { "SysAVG": -1, "DiaAVG": -1, "PulsAVG": -1 }
  // ];

  void _loadData() async {
    final data = await dbHelper.getDataDays(7);
    setState(() {
      if ( data[0]['SysAVG'] != null && data[0]['DiaAVG'] != null && data[0]['PulsAVG'] != null ) {
        strAnzahl = data.length.toString();
        strSysAVG = data[0]['SysAVG'].toString() + ' mmHg';
        strDiaAVG = data[0]['DiaAVG'].toString() + ' mmHg';
        strPulsAVG = data[0]['PulsAVG'].toString() + ' bps';
      }
    });
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: '?',
    packageName: '?',
    version: '?',
    buildNumber: '?',
    buildSignature: '?',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _loadData();
  }

  PackageInfo get getPackageInfo {
    return _packageInfo;
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
      globals.gPackageInfo = info;
      globals.screenwidth = window.physicalSize.width.toInt();
      globals.screenheight = window.physicalSize.height.toInt();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('noch zu programmieren...'),
              backgroundColor: Color.fromARGB(0xff, 0xbd, 0xbd, 0xbd)
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gesundheitsdaten'),
          actions: <Widget>[
            // die Widgets werden von rechts außen nach links aufgeführt
            IconButton(
              icon: Icon(Icons.info_outlined),
              onPressed: () {
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    child: InfoPage(),
                    alignment: Alignment.topCenter,
                    type: PageTransitionType.leftToRightWithFade,),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings_sharp),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('noch zu programmieren...'),
                    backgroundColor: Color.fromARGB(0xff, 0xbd, 0xbd, 0xbd)
                  )
                );
              },
            ),
          ],
        ),
        drawer: myMenuWidget(ThePackageInfo: _packageInfo),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Container(
                  width: 310,
                  //height: 550,
                  child: Card(
                    elevation: 5.0,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Image.asset(
                              "lib/assets/images/stethoscope.jpg",
                              fit: BoxFit.cover,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('Bildquelle:',
                                  textScaleFactor: 0.8,
                                ),
                                TextButton(
                                  onPressed: () {
                                    _launchURL(); //action
                                  },
                                  child: const Text(
                                    'hier klicken', //title
                                    textAlign: TextAlign.end, //aligment
                                    textScaleFactor: 0.8,
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 25.0, 0, 10),
                                  child: Text(
                                    'Gesundheitsdaten',
                                    textAlign: TextAlign.start,
                                    textScaleFactor: 1.8,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            meineZeile( Beschreibung: 'berücksichtigte Einträge:', Wert: strAnzahl ),
                            meineZeile( Beschreibung: 'Systole:', Wert: strSysAVG ),
                            meineZeile( Beschreibung: 'Diastole:', Wert: strDiaAVG ),
                            meineZeile( Beschreibung: 'Puls:', Wert: strPulsAVG ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Text(
                                'Bei diesen Werten handelt es sich um Mittelwerte der letzten 7 Tage.',
                                textScaleFactor: 0.8,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
        BottomNavigationBar(items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Start',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_rows),
            label: 'Einträge',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class myMenuWidget extends StatelessWidget {
  final PackageInfo ThePackageInfo;

  myMenuWidget({
    Key? key, required this.ThePackageInfo,
  }) : super(key: key,);

  static TapRoutine(BuildContext context, int Index)  {
    String x = "?";
    switch(Index) {
      case 1:
        x = "Einträge ansehen...";
        break;
      case 2:
        x = "Einstellungen...";
        break;
      case 3:
        x = "Statistik...";
        break;
      case 4:
        x = "Import / Export...";
        break;
      case 5:
        x = "Über diese App...";
        break;
      default:
        x = "unbekannter Aufruf!";
        break;
    }
    if (Index == 5 ) {
      Navigator.push(
        context,
        PageTransition(
          child: InfoPage(),
          alignment: Alignment.topCenter,
          type: PageTransitionType.leftToRightWithFade,),
      );
    } else {
      return showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: const Text('noch zu programmieren...'),
              content: Text(x),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[200],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  this.ThePackageInfo.appName,
                  textScaleFactor: 2.0,
                ),
                Text(
                  'Version: ' + this.ThePackageInfo.version,
                  textScaleFactor: 1.3,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.table_rows),
            title: Text(
              'Einträge ansehen...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context);
              TapRoutine(context, 1,);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_sharp),
            title: Text(
              'Einstellungen...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context);
              TapRoutine(context, 2);
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics_outlined),
            title: Text(
              'Statistik...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context);
              TapRoutine(context, 3);
            },
          ),
          ListTile(
            leading: Icon(Icons.import_export_outlined),
            title: Text(
              'Import / Export...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context);
              TapRoutine(context, 4);
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outlined),
            title: Text(
              'Über diese App...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context);
              TapRoutine(context, 5);
            },
          ),
        ],
      ),
    );
  }
}

class meineZeile extends StatelessWidget {
  final String Beschreibung;
  final String Wert;

  const meineZeile({
    Key? key,
    required this.Beschreibung,
    required this.Wert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      //color: Colors.grey[200],
      height: 33,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            this.Beschreibung,
            textAlign: TextAlign.start,
            textScaleFactor: 1.2,
          ),
          Text(
            this.Wert,
            textAlign: TextAlign.end,
            textScaleFactor: 1.2,
          )
        ],
      ),
    );
  }
}

void _launchURL() async {
  const _url =
      'https://pixabay.com/de/photos/stethoskop-arzt-medizin-medizinisch-1584222/';
  if (await canLaunch(_url)) {
    await launch(_url);
  } else {
    throw 'Fehler beim Aufruf von $_url';
  }
}
