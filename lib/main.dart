import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sysdiapulsgew/pages/InfoPage/infopage.dart';
import 'package:sysdiapulsgew/pages/StatistikPage/statistikpage.dart';
import 'package:sysdiapulsgew/pages/StatistikPage/statistikdata.dart' as stats;
import 'package:sysdiapulsgew/pages/ImportExportPage/importexportpage.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import 'package:sysdiapulsgew/pages/EntriesTablePage/entriestablepage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'my-globals.dart' as globals;
import 'dart:ui';
import 'package:badges/badges.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

dynamic _platform;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    // die App soll ausschließlich im Hochkantformat arbeiten
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    _platform = Theme.of(context).platform;
    globals.BgColorNeutral = Theme.of(context).scaffoldBackgroundColor;
    return MaterialApp(
      title: 'SysDiaPulsGew',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const MyHomePage(title: 'SysDiaPulsGew'),
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de', 'DE')], //, Locale('pt', 'BR')],
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/entriestablepage':
            return MaterialPageRoute(
              builder: (_) => EntriesTablePage(),
              maintainState: false,
            );
          case '/importexportpage':
            return PageTransition(
              child: ImportExportPage(),
              type: PageTransitionType.fade,
              settings: settings,
              reverseDuration: const Duration(seconds: 3),
            );
          case '/infopage':
            return MaterialPageRoute(
              builder: (_) => InfoPage(),
              maintainState: false,
            );
          case '/statistikpage':
            return MaterialPageRoute(
              builder: (_) => StatistikPage(),
              maintainState: false,
            );
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
  String strAnzDSe = '?';
  Timer? myTimer;

  Future<void> _loadAVGData() async {
    final d1 = await dbHelper.getEntryCount();
    final data = await dbHelper.getDataDays(-7);
    if ( mounted ) {
      setState(() {
        if (d1[0]['Cnt'] != null) {
          strAnzDSe = d1[0]['Cnt'].toString();
        } else {
          strAnzDSe = "0";
        }
        if ( data[0]['SysAVG'] != null && data[0]['DiaAVG'] != null && data[0]['PulsAVG'] != null ) {
          strSysAVG = data[0]['SysAVG'].toString();
          strDiaAVG = data[0]['DiaAVG'].toString();
          strPulsAVG = data[0]['PulsAVG'].toString();
        } else {
        }
      });
    }
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: '?',
    packageName: '?',
    version: '?',
    buildNumber: '?',
    buildSignature: '?',
  );

  Future<void> loadAllData() async {
    if ( await dbHelper.istDB_OK() ) {
      await _getStoragePermission();
      await _initPackageInfo();
      await _loadAVGData();
    }
  }

  Future<void> myTimerTick() async {
    if ( globals.updAVG_needed == true ) {
      if (kDebugMode) {
        print('myTimerTick Anfang: ' + DateTime.now().toString());
      }
      await _loadAVGData();
      setState(() {
        globals.updAVG_needed = false;
      });
      if (kDebugMode) {
        print('myTimerTick Ende: ' + DateTime.now().toString());
      }
    }
  }
  @override
  void initState() {
    super.initState();
    loadAllData();
    // mit dem Timer wird regelmäßig dafür gesorgt, dass die Mittelwerte aktuell angezeigt werden
    myTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await myTimerTick();
    });
  }

  @override
  void dispose() {
    super.dispose();
    myTimer!.cancel();
  }

  PackageInfo get getPackageInfo {
    return _packageInfo;
  }

  bool permissionGranted = false;
  Future _getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      if ( mounted ) {
        setState(() {
          permissionGranted = true;
        });
      }
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      if ( mounted ) {
        setState(() {
          permissionGranted = false;
        });
      }
    }
    if ( permissionGranted == true ) {
      try {
        if ( (Directory(globals.lokalDBPfad)).exists() == false ) {
          if (kDebugMode) {
            print("Verzeichnis " + globals.lokalDBPfad + " erzeugt");
          }
        } else {
          if (kDebugMode) {
            print("Verzeichnis " + globals.lokalDBPfad + " existiert");
          }
        }
      } on Error catch (_,e) {
        if (kDebugMode) {
          print('Fehler beim Erzeugen des Verzeichnisses ' + globals.lokalDBPfad + ' - ' + e.toString());
        }
      }
    }
  }

  Future<Directory?> getExternalStorageDirectory() async {
    final String? path = await _platform.getExternalStoragePath();
    if (path == null) {
      return null;
    } else {
      globals.lokalDBDir = path;
      globals.lokalDBPfad = path + "SysDiaPuls/";
      globals.lokalDBNameMitPfad = globals.lokalDBPfad + globals.lokalDBNameOhnePfad;
    }
    print("getExternalStorageDirectory: " + path);
    print("lokalDBDir: " + globals.lokalDBDir);
    print("lokalDBPfad: " + globals.lokalDBPfad);
    print("lokalDBNameMitPfad: " + globals.lokalDBNameMitPfad);
    return Directory(path);
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if ( mounted ) {
      setState(() {
        _packageInfo = info;
        globals.gPackageInfo = info;
        globals.screenwidth = window.physicalSize.width.toInt();
        globals.screenheight = window.physicalSize.height.toInt();
      });
    }
  }

  void _onItemTapped(int index) async {
    if ( mounted ) {
      switch (index) {
        case 0:                     // Start oder Home
          break;
        case 1:                     // Statistik
          await stats.ladeDaten();
          await Navigator.push(
            context,
            PageTransition(
              child: const StatistikPage(),
              alignment: Alignment.topCenter,
              type: PageTransitionType.leftToRightWithFade,),
          );
          break;
        case 2:                     // Einträge
          await Navigator.push(
            context,
            PageTransition(
              child: const EntriesTablePage(),
              alignment: Alignment.topCenter,
              type: PageTransitionType.leftToRightWithFade,),
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gesundheitsdaten'),
          actions: <Widget>[
            // die Widgets werden von rechts außen nach links aufgeführt
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
                  width: globals.CardWidth,
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
                            //meineZeile( Beschreibung: 'berücksichtigte Einträge:', Wert: strAnzDSe ),
                            meineZeile( Beschreibung: 'Systole (mmHg):', Wert: strSysAVG ),
                            meineZeile( Beschreibung: 'Diastole (mmHg):', Wert: strDiaAVG ),
                            meineZeile( Beschreibung: 'Puls (bps):', Wert: strPulsAVG ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Text(
                                'Bei diesen Werten handelt es sich um Mittelwerte der letzten 7 erfassten Tage.',
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
        BottomNavigationBar(items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Start',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              child: Icon(Icons.table_rows),
              badgeColor: Colors.blue,
              position: BadgePosition.topEnd(),
              shape: BadgeShape.square,
              borderRadius: BorderRadius.circular(8),
              padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
              badgeContent: Text(strAnzDSe,style: TextStyle(color: globals.BgColorNeutral),textScaleFactor: 0.8,),
            ),
            label: 'Einträge',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class myMenuWidget extends StatefulWidget {
  final PackageInfo ThePackageInfo;

  const myMenuWidget({
    Key? key, required this.ThePackageInfo,
  }) : super(key: key,);

  static TapRoutine(BuildContext context, int Index) async {
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
    if (Index == 1 ) {
      await Navigator.push(
        context,
        PageTransition(
          child: const EntriesTablePage(),
          alignment: Alignment.topCenter,
          type: PageTransitionType.leftToRightWithFade,),
      );
    } else if (Index == 3 ) {
      await Navigator.push(
        context,
        PageTransition(
          child: const StatistikPage(),
          alignment: Alignment.topCenter,
          type: PageTransitionType.leftToRightWithFade,),
      );
    } else if (Index == 4 ) {
      await Navigator.push(
        context,
        PageTransition(
          child: const ImportExportPage(),
          alignment: Alignment.topCenter,
          type: PageTransitionType.leftToRightWithFade,),
      );
    } else if (Index == 5 ) {
      await Navigator.push(
        context,
        PageTransition(
          child: const InfoPage(),
          alignment: Alignment.topCenter,
          type: PageTransitionType.leftToRightWithFade,),
      );
    } else {
      return await showDialog<String>(
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
  State<myMenuWidget> createState() => _myMenuWidgetState();
}

class _myMenuWidgetState extends State<myMenuWidget> {

  @override
  void initState() {
    super.initState();
  }

  void _setState() async {
    if ( mounted ) {
      setState(() {
        // _MyHomePageState();
      });
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
                  widget.ThePackageInfo.appName,
                  textScaleFactor: 2.0,
                ),
                Text(
                  'Version: ' + widget.ThePackageInfo.version,
                  textScaleFactor: 1.3,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.table_rows),
            title: const Text(
              'Einträge ansehen...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context);
              myMenuWidget.TapRoutine(context, 1,);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_sharp),
            title: const Text(
              'Einstellungen...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context);
              myMenuWidget.TapRoutine(context, 2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text(
              'Statistik...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context);
              myMenuWidget.TapRoutine(context, 3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.import_export_outlined),
            title: const Text(
              'Import / Export...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context); // nimmt das Menü wieder weg
              //myMenuWidget.TapRoutine(context, 4);
              Navigator.of(context)
                .push(MaterialPageRoute(
                  builder: (context) => ImportExportPage(),
                ))
                .then((value) =>
                {
                  if ( mounted ) setState(() { _setState(); } )
                }
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: const Text(
              'Über diese App...',
              textScaleFactor: 1.5,
            ),
            onTap: () {
              Navigator.pop(context);
              myMenuWidget.TapRoutine(context, 5);
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
            Beschreibung,
            textAlign: TextAlign.start,
            textScaleFactor: 1.2,
          ),
          Text(
            Wert,
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
      'https://pixabay.com/vectors/stethoscope-icon-medical-medicine-3725131/';
  if (await canLaunch(_url)) {
    await launch(_url);
  } else {
    throw 'Fehler beim Aufruf von ' + _url;
  }
}
