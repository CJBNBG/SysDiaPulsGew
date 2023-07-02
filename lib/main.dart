import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sysdiapulsgew/pages/DailyEntriesTablePage/dailyentriestablepage.dart';
import 'package:sysdiapulsgew/pages/DiagramPage/diagrampage.dart';
import 'package:sysdiapulsgew/pages/EntriesPage/utils.dart';
import 'package:sysdiapulsgew/pages/SettingsPage/settingspage.dart';
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
import 'myUpdateProvider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_localization/flutter_localization.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:syncfusion_flutter_core/core.dart';

void main() {
  // Register Syncfusion license
  // SyncfusionLicense.registerLicense("Mgo+DSMBaFt+QHJqVk1hXk5Hd0BLVGpAblJ3T2ZQdVt5ZDU7a15RRnVfRFxiSH5TdUBnWHpYdg==;Mgo+DSMBPh8sVXJ1S0R+X1pFdEBBXHxAd1p/VWJYdVt5flBPcDwsT3RfQF5jT39Sd0VjWnpacXNVQA==;ORg4AjUWIQA/Gnt2VFhiQlJPd11dXmJWd1p/THNYflR1fV9DaUwxOX1dQl9gSXhSd0RjWXxbdHVdQGY=;MjM4MTc3OEAzMjMxMmUzMDJlMzBnVzUwbzNSV2EraDltNXVFVDh1SUFhaUVMNFdEeTBnUzJFckJOU1Y3UG9rPQ==;MjM4MTc3OUAzMjMxMmUzMDJlMzBINTJRcjNEemU5cmNHcXJJR3RTVjEyWU8rdkZOSFJjUHRKQWR2NDJyd253PQ==;NRAiBiAaIQQuGjN/V0d+Xk9HfV5AQmBIYVp/TGpJfl96cVxMZVVBJAtUQF1hSn5Vd0RiWX9ddXBXQGVa;MjM4MTc4MUAzMjMxMmUzMDJlMzBLY3pFWXdubE1Xa1krVC90alhNNlQrZ0EzOExpSkxkSW5sc3N3WVpPajlvPQ==;MjM4MTc4MkAzMjMxMmUzMDJlMzBGYUdmT24zd2IwYk0xMXZOaVZmYU9JQUtCckR5UTFWTVp3VlphYkpNNjlvPQ==;Mgo+DSMBMAY9C3t2VFhiQlJPd11dXmJWd1p/THNYflR1fV9DaUwxOX1dQl9gSXhSd0RjWXxbdHdWT2Y=;MjM4MTc4NEAzMjMxMmUzMDJlMzBSZGw3OE9wcEFYMmtIT0tVeTFyL2IxZDg2ZUpNS1g4aUxFZk4rRm9CeXRzPQ==;MjM4MTc4NUAzMjMxMmUzMDJlMzBiejJ6Z2twV1d5emJtWjNTRU84WDc3SzloTERYajVZdGdtWGlPUytDblJjPQ==;MjM4MTc4NkAzMjMxMmUzMDJlMzBLY3pFWXdubE1Xa1krVC90alhNNlQrZ0EzOExpSkxkSW5sc3N3WVpPajlvPQ==");
  // initializeDateFormatting().then((_) =>
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => myUpdateProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
    initializeDateFormatting('de_DE', null);
    super.initState();
    // die App soll ausschließlich im Hochkantformat arbeiten
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (kDebugMode) {
      print('App arbeitet nur im Hochkantformat');
    }
  }

  @override
  Widget build(BuildContext context) {
    _platform = Theme.of(context).platform;
    globals.BgColorNeutral = Theme.of(context).scaffoldBackgroundColor;
    return MaterialApp(
      title: 'SysDiaPG',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const MyHomePage(title: 'SysDiaPG'),
      // localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // supportedLocales: const <Locale>[Locale('de', 'DE')], //, Locale('pt', 'BR')],
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/entriestablepage':
            return MaterialPageRoute(
              builder: (_) => const EntriesTablePage(),
              maintainState: false,
            );
          case '/dailyentriestablepage':
            return MaterialPageRoute(
              builder: (_) => const dailyEntriesTablePage(),
              maintainState: false,
            );
          case '/importexportpage':
            return PageTransition(
              child: const ImportExportPage(),
              type: PageTransitionType.fade,
              settings: settings,
              reverseDuration: const Duration(seconds: 3),
            );
          case '/infopage':
            return MaterialPageRoute(
              builder: (_) => const InfoPage(),
              maintainState: false,
            );
          case '/statistikpage':
            return MaterialPageRoute(
              builder: (_) => const StatistikPage(),
              maintainState: false,
            );
          case '/settingspage':
            return MaterialPageRoute(
              builder: (_) => const SettingsPage(),
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
  final FlutterLocalization _localization = FlutterLocalization.instance;
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
        if (d1 != null) {
          strAnzDSe = d1.toString();
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
      await _initGroesse();
      await _loadAVGData();
      await ladeEintraege();
      await ladeEvents();
      final erg = await dbHelper.getFirstEntry();
      if ( erg.isNotEmpty ) {
        globals.calendarStart = DateTime.parse(erg[0]['Zeitpkt'].toString());
      } else {
        globals.calendarStart = DateTime.parse('2022-01-01 00:00');
      }
      if (kDebugMode) {
        print(globals.calendarStart);
      }
      List<Map<String, dynamic>> allEntries = await dbHelper.getDataItems(-1);
    } else {
      if (kDebugMode) {
        print("Datenbank ist NICHT OK!!!!");
      }
    }
    if (kDebugMode) {
      print("Version: ${globals.gPackageInfo.version} ( ${globals.gPackageInfo.buildNumber} )");
    }
  }

  Future<void> myTimerTick() async {
    if ( globals.updAVG_needed == true ) {
      if (kDebugMode) {
        print('myTimerTick Anfang: ${DateTime.now()}');
      }
      await _loadAVGData();
      await ladeEintraege();
      await ladeEvents();
      setState(() {
        globals.updAVG_needed = false;
      });
      if (kDebugMode) {
        print('myTimerTick Ende: ${DateTime.now()}');
      }
    }
  }
  @override
  void initState() {
    _localization.init(
      mapLocales: [
        const MapLocale('de', AppLocale.DE),
      ],
      initLanguageCode: 'de',
    );
    _localization.onTranslatedLanguage = _onTranslatedLanguage;
    super.initState();
    loadAllData();
    // mit dem Timer wird regelmäßig dafür gesorgt, dass die Mittelwerte aktuell angezeigt werden
    myTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await myTimerTick();
    });
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
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
    final folder = Directory(globals.lokalDBPfad);
    final otherFolder = await getExternalStorageDirectories(type: StorageDirectory.downloads);
    print("ExternalStorageDirectories=$otherFolder");
    // final _result = await Permission.storage.request();
    final _result = await Permission.storage.status;
    switch (_result) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        print("Zugriff erlaubt");
        break;

      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.provisional:          // nur bei iOS
      default:
        print("Zugriff verweigert: $_result");
    }
    if (await Permission.storage.request().isGranted) {
      if ( mounted ) {
        setState(() {
          permissionGranted = true;
        });
      }
    } else {
      if ( mounted ) {
        setState(() {
          permissionGranted = false;
        });
      }
    }
    if ( permissionGranted == true ) {
      print("Zugriffsrechte für $folder liegen vor");
    } else {
      print("Zugriffsrechte für $folder fehlen");
    }
  }

  Future<Directory?> getExternalStorageDirectory() async {
    final String? path = await _platform.getExternalStoragePath();
    if (path == null) {
      return null;
    } else {
      globals.lokalDBDir = path;
      globals.lokalDBPfad = "${path}SysDiaPulsGew/";
      globals.lokalDBNameMitPfad = globals.lokalDBPfad + globals.lokalDBNameOhnePfad;
    }
    if (kDebugMode) {
      print("getExternalStorageDirectory: $path");
      print("lokalDBDir: ${globals.lokalDBDir}");
      print("lokalDBPfad: ${globals.lokalDBPfad}");
      print("lokalDBNameMitPfad: ${globals.lokalDBNameMitPfad}");
    }
    return Directory(path);
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if ( mounted ) {
      setState(() {
        _packageInfo = info;
        globals.gPackageInfo = info;
        globals.screenwidth = View.of(context).physicalSize.width.toInt();
        globals.screenheight = View.of(context).physicalSize.height.toInt();
      });
    }
  }

  Future<void> _initGroesse() async {
    final double gr = await dbHelper.getGroesse();
    if ( mounted ) {
      setState(() {
        globals.gGroesse = gr;
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
        case 2:                     // Diagramm
          await Navigator.push(
            context,
            PageTransition(
              child: const diagramPage(),
              alignment: Alignment.topCenter,
              type: PageTransitionType.leftToRightWithFade,),
          );
          break;
        case 3:                     // Einträge
          await Navigator.push(
            context,
            PageTransition(
              child: const EntriesTablePage(),
              alignment: Alignment.topCenter,
              type: PageTransitionType.leftToRightWithFade,),
          );
          break;
        default:
          print("unbekannter index: $index");
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
          title: const Text('SysDiaPG'),
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
        drawer: myMenuWidget(ThePackageInfo: _packageInfo),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: SizedBox(
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
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 5.0, 0, 10),
                                    child: Text(
                                      'Blutdruck- und Gewichtsdaten',
                                      textAlign: TextAlign.start,
                                      textScaleFactor: 1.8,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Statistik',
          ),
          const BottomNavigationBarItem(
            icon: Icon(MdiIcons.chartScatterPlot),
            label: 'Diagramm',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              badgeColor: Theme.of(context).primaryColor,
              position: badges.BadgePosition.topEnd(),
              shape: badges.BadgeShape.square,
              borderRadius: BorderRadius.circular(8),
              padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
              badgeContent: Text(strAnzDSe,style: TextStyle(color: globals.BgColorNeutral),textScaleFactor: 0.8,),
              child: const Icon(Icons.table_rows),
            ),
            label: 'Einträge',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
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

  static _tapRoutine(BuildContext context, int Index) async {
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
        await stats.ladeDaten();
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
    } else if (Index == 2 ) {
      await Navigator.push(
        context,
        PageTransition(
          child: const SettingsPage(),
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
                  int.parse(globals.gPackageInfo.buildNumber) > 0 ? 'Version: ${globals.gPackageInfo.version} (${globals.gPackageInfo.buildNumber})' : 'Version: ${globals.gPackageInfo.version}', //title
                  // 'Version: ' + widget.ThePackageInfo.version + ' (' + widget.ThePackageInfo.buildNumber + ')',
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
              myMenuWidget._tapRoutine(context, 1,);
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
              myMenuWidget._tapRoutine(context, 2);
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
              myMenuWidget._tapRoutine(context, 3);
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
                  builder: (context) => const ImportExportPage(),
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
              myMenuWidget._tapRoutine(context, 5);
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
  final Uri _url = Uri.parse('https://pixabay.com/photos/blood-pressure-stethoscope-medical-1584223/');
  if (await canLaunchUrl(_url)) {
    await launchUrl(_url);
  } else {
    throw 'Fehler beim Aufruf von $_url';
  }
}

mixin AppLocale {
  static const String title = 'title';

  static const Map<String, dynamic> DE = {title: 'Lokalisierung'};
}