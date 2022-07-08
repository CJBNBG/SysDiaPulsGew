import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../my-globals.dart' as globals;
import '../../services/myWidgets.dart' as myWidgets;
import 'package:sysdiapulsgew/services/dbhelper.dart';

const ContainerWidth = 310.0;
const PaddingWidth = 8.0;
const EntryWidthSysDia = (ContainerWidth-2.0*PaddingWidth-8.0)/3.0;
const EntryWidthGew = (ContainerWidth-2.0*PaddingWidth-8.0);
String strAnzDSe = '';
String strZeitpunkt = '?';
String strTage = '?';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

  void _AnzDSe() async {
    int? ret = await dbHelper.getEntryCount();
    if ( mounted ) setState(() {
      if (ret != null) {
        strAnzDSe = ret.toString();
      } else {
        strAnzDSe = '?';
      }
    });
  }

  void _getLastEntry() async {
    List<Map<String, dynamic>> ret = await dbHelper.getLastEntry();
    if ( mounted ) {
      setState(() {
      if (ret.isNotEmpty) {
        strZeitpunkt = ret[0]['Zeitpkt'].toString();
        int iTag = int.parse(strZeitpunkt.substring(0, 2));
        int iMonat = int.parse(strZeitpunkt.substring(3, 5));
        int iJahr = int.parse(strZeitpunkt.substring(6, 10));
        DateTime a = DateTime(iJahr, iMonat, iTag);
        DateTime b = DateTime.now();
        Duration d = b.difference(a);
        strTage = d.inDays.toString();
      }
    });
    }
  }

  @override
  void initState() {
    super.initState();
    _AnzDSe();
    _getLastEntry();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Über diese App'
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Container(
                  width: ContainerWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.all(PaddingWidth),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                                child: Text(
                                  "Autor:",
                                  textScaleFactor: 1.25,
                                  style: TextStyle(
                                    //color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
                                child: Text(
                                  "Claus J. Bauer",
                                  textScaleFactor: 2.0,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 2.0, 0, 0),
                                child: Row(
                                  children: [
                                    Text(
                                      "Kontakt:",
                                      textScaleFactor: 1.25,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _launchEMail(); //action
                                      },
                                      child: const Text(
                                        'EMail an den Autor', //title
                                        textAlign: TextAlign.end, //aligment
                                        textScaleFactor: 1.25,
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 1.0, 0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Version: ",
                                      textScaleFactor: 1.0,
                                    ),
                                    Text(
                                      globals.gPackageInfo.version + ' (' + globals.gPackageInfo.buildNumber + ')', //title
                                      textScaleFactor: 1.0,
                                    ),
                                  ],
                                ),
                              ),
                              myListWidget(Titel: "Name der App: ", Wert: globals.gPackageInfo.appName, ScaleFactor: 1.0,),
                              // myListWidget(Titel: "Packagename: ", Wert: globals.gPackageInfo.packageName, ScaleFactor: 1.0,),
                              // myListWidget(Titel: "Buildsignature: ", Wert: globals.gPackageInfo.buildSignature, ScaleFactor: 0.67,),
                              myListWidget(Titel: "Anzeigeformat: ", Wert: globals.screenwidth.toString() + ' x ' + globals.screenheight.toString(), ScaleFactor: 1.0,),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 5.0,
                        child: Padding(
                          padding: EdgeInsets.all(PaddingWidth),
                          child: Container(
                            width: ContainerWidth,
                            //height: 55,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                                  child: Text(
                                    "Informationen zur Datenbank:",
                                    textScaleFactor: 1.25,
                                    style: TextStyle(
                                      //color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                myListWidget(Titel: "Anzahl Einträge: ", Wert: strAnzDSe, ScaleFactor: 1.0,),
                                myListWidget(Titel: "letzter Eintrag vom: ", Wert: strZeitpunkt, ScaleFactor: 1.0,),
                                myListWidget(Titel: "", Wert: '($strTage Tage)', ScaleFactor: 1.0,),
                              ],
                            ),
                          ),
                        ),
                      ),


                      // ab hier werden die verwendeten Farben dargestellt
                      // -------------------------------------------------
                      Card(
                        elevation: 5.0,
                        child: Padding(
                          padding: EdgeInsets.all(PaddingWidth),
                          child: Container(
                            width: ContainerWidth,
                            // height: 405,
                            //color: Colors.lightBlue[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10.0,),
                                Text(
                                  'verwendete Farben:',
                                  textScaleFactor: 1.25,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20.0,),
                                myListWidget(Titel: "Systole (mmHg):", Wert: "", ScaleFactor: 1.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'optimal:',
                                        Titel2: 'unter 120',
                                        Farbe1: globals.SysDia_optimal,
                                        Farbe2: globals.SysDia_optimal_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'normal:',
                                        Titel2: '120 - 129',
                                        Farbe1: globals.SysDia_normal,
                                        Farbe2: globals.SysDia_normal_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'hochnormal:',
                                        Titel2: '130 - 139',
                                        Farbe1: globals.SysDia_hochnormal,
                                        Farbe2: globals.SysDia_hochnormal_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'Stufe 1:',
                                        Titel2: '140 - 159',
                                        Farbe1: globals.SysDia_Stufe_1,
                                        Farbe2: globals.SysDia_Stufe_1_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'Stufe 2:',
                                        Titel2: '160 - 179',
                                        Farbe1: globals.SysDia_Stufe_2,
                                        Farbe2: globals.SysDia_Stufe_2_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'Stufe 3:',
                                        Titel2: 'ab 180',
                                        Farbe1: globals.SysDia_Stufe_3,
                                        Farbe2: globals.SysDia_Stufe_3_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.0,),
                                myListWidget(Titel: "Diastole (mmHg):", Wert: "", ScaleFactor: 1.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'optimal:',
                                        Titel2: 'unter 80',
                                        Farbe1: globals.SysDia_optimal,
                                        Farbe2: globals.SysDia_optimal_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'normal:',
                                        Titel2: '80 - 84',
                                        Farbe1: globals.SysDia_normal,
                                        Farbe2: globals.SysDia_normal_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'hochnormal:',
                                        Titel2: '85 - 89',
                                        Farbe1: globals.SysDia_hochnormal,
                                        Farbe2: globals.SysDia_hochnormal_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'Stufe 1:',
                                        Titel2: '90 - 99',
                                        Farbe1: globals.SysDia_Stufe_1,
                                        Farbe2: globals.SysDia_Stufe_1_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'Stufe 2:',
                                        Titel2: '100 - 109',
                                        Farbe1: globals.SysDia_Stufe_2,
                                        Farbe2: globals.SysDia_Stufe_2_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'Stufe 3:',
                                        Titel2: 'ab 110',
                                        Farbe1: globals.SysDia_Stufe_3,
                                        Farbe2: globals.SysDia_Stufe_3_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.0,),
                                myListWidget(Titel: "Puls (bpm):", Wert: "", ScaleFactor: 1.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'langsam:',
                                        Titel2: 'unter 60',
                                        Farbe1: globals.Puls_langsam,
                                        Farbe2: globals.Puls_langsam_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'normal:',
                                        Titel2: '60 - 99',
                                        Farbe1: globals.Puls_normal,
                                        Farbe2: globals.Puls_normal_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myWidgets.myListRowWidgetTwoLines(
                                        Titel1: 'schnell:',
                                        Titel2: 'ab 100',
                                        Farbe1: globals.Puls_schnell,
                                        Farbe2: globals.Puls_schnell_blass,
                                        Breite: EntryWidthSysDia,
                                        ScaleFactor: 1.0,
                                        isHeader: false,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.0,),
                                myListWidget(Titel: "Gewicht (kg):", Wert: "", ScaleFactor: 1.0),
                                Container(
                                  height: 50, width: EntryWidthGew, color: Colors.lightBlue[200],
                                  child: myWidgets.myListRowWidgetTwoLines(
                                    Titel1: 'normal:',
                                    Titel2: '0.0 - 300.0',
                                    Farbe1: globals.Gewicht_normal,
                                    Farbe2: globals.Gewicht_normal_blass,
                                    Breite: EntryWidthGew,
                                    ScaleFactor: 1.0,
                                    isHeader: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      )
    );
  }
}

class myListWidget extends StatelessWidget {
  final String Titel;
  final String Wert;
  final double ScaleFactor;
  const myListWidget({
    Key? key, required this.Titel, required this.Wert, required this.ScaleFactor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            this.Titel,
            textScaleFactor: this.ScaleFactor,
          ),
          Text(
            this.Wert, //title
            textScaleFactor: this.ScaleFactor,
          ),
        ],
      ),
    );
  }
}

void _launchEMail() async {
  final Uri _url =
      Uri.parse('mailto:claus@clausjbauer.de?subject=[SysDiaPulsGew]&body=Hier bitte den Text an den Autor ergänzen...');
  if (await canLaunchUrl(_url)) {
    await launchUrl(_url);
  } else {
    throw 'Fehler beim Aufruf von $_url.toString()';
  }
}
