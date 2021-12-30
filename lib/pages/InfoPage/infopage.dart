import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../my-globals.dart' as globals;
import 'package:sysdiapulsgew/services/dbhelper.dart';

const ContainerWidth = 310.0;
const PaddingWidth = 8.0;
const EntryWidthSysDia = (ContainerWidth-2.0*PaddingWidth-8.0)/3.0;
const EntryWidthGew = (ContainerWidth-2.0*PaddingWidth-8.0);
String strAnzDSe = '';
String strZeitpunkt = '';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {

  void _AnzDSe() async {
    List<Map<String, dynamic>> ret = await dbHelper.getEntryCount();
    if ( mounted ) setState(() {
      if (ret.isNotEmpty) {
        strAnzDSe = ret[0]['Cnt'].toString();
      } else {
        strAnzDSe = '?';
      }
    });
  }

  void _getLastEntry() async {
    List<Map<String, dynamic>> ret = await dbHelper.getLastEntry();
    if ( mounted ) setState(() {
      if (ret.isNotEmpty) {
        strZeitpunkt = ret[0]['Zeitpkt'].toString();
      } else {
        strZeitpunkt = '?';
      }
    });
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
                                      globals.gPackageInfo.version, //title
                                      textScaleFactor: 1.0,
                                    ),
                                  ],
                                ),
                              ),
                              myListWidget(Titel: "Name der App: ", Wert: globals.gPackageInfo.appName, ScaleFactor: 1.0,),
                              myListWidget(Titel: "Packagename: ", Wert: globals.gPackageInfo.packageName, ScaleFactor: 1.0,),
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
                            height: 405,
                            //color: Colors.lightBlue[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'verwendete Farben:',
                                  textScaleFactor: 1.25,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                myListWidget(Titel: "Systole (mmHg):", Wert: "", ScaleFactor: 1.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'optimal:', Titel2: 'unter 120', Farbe1: globals.SysDia_optimal, Farbe2: globals.SysDia_optimal_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'normal:', Titel2: '120 - 129', Farbe1: globals.SysDia_normal, Farbe2: globals.SysDia_normal_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'hochnormal:', Titel2: '130 - 139', Farbe1: globals.SysDia_hochnormal, Farbe2: globals.SysDia_hochnormal_blass, Breite: EntryWidthSysDia,),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'Stufe 1:', Titel2: '140 - 159', Farbe1: globals.SysDia_Stufe_1, Farbe2: globals.SysDia_Stufe_1_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'Stufe 2:', Titel2: '160 - 179', Farbe1: globals.SysDia_Stufe_2, Farbe2: globals.SysDia_Stufe_2_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'Stufe 3:', Titel2: 'ab 180', Farbe1: globals.SysDia_Stufe_3, Farbe2: globals.SysDia_Stufe_3_blass, Breite: EntryWidthSysDia,),
                                    ),
                                  ],
                                ),
                                myListWidget(Titel: "Diastole (mmHg):", Wert: "", ScaleFactor: 1.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'optimal:', Titel2: 'unter 120', Farbe1: globals.SysDia_optimal, Farbe2: globals.SysDia_optimal_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'normal:', Titel2: '120 - 129', Farbe1: globals.SysDia_normal, Farbe2: globals.SysDia_normal_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'hochnormal:', Titel2: '130 - 139', Farbe1: globals.SysDia_hochnormal, Farbe2: globals.SysDia_hochnormal_blass, Breite: EntryWidthSysDia,),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'Stufe 1:', Titel2: '140 - 159', Farbe1: globals.SysDia_Stufe_1, Farbe2: globals.SysDia_Stufe_1_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'Stufe 2:', Titel2: '160 - 179', Farbe1: globals.SysDia_Stufe_2, Farbe2: globals.SysDia_Stufe_2_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'Stufe 3:', Titel2: 'ab 180', Farbe1: globals.SysDia_Stufe_3, Farbe2: globals.SysDia_Stufe_3_blass, Breite: EntryWidthSysDia,),
                                    ),
                                  ],
                                ),
                                myListWidget(Titel: "Puls (bps):", Wert: "", ScaleFactor: 1.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'langsam:', Titel2: 'unter 60', Farbe1: globals.Puls_langsam, Farbe2: globals.Puls_langsam_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'normal:', Titel2: '60 - 99', Farbe1: globals.Puls_normal, Farbe2: globals.Puls_normal_blass, Breite: EntryWidthSysDia,),
                                    ),
                                    Container(
                                      height: 50, width: EntryWidthSysDia, color: Colors.lightBlue[200],
                                      child: myListRowWidget(Titel1: 'schnell:', Titel2: 'ab 100', Farbe1: globals.Puls_schnell, Farbe2: globals.Puls_schnell_blass, Breite: EntryWidthSysDia,),
                                    ),
                                  ],
                                ),
                                myListWidget(Titel: "Gewicht (kg):", Wert: "", ScaleFactor: 1.0),
                                Container(
                                  height: 50, width: EntryWidthGew, color: Colors.lightBlue[200],
                                  child: myListRowWidget(Titel1: 'normal:', Titel2: '0.0 - 300.0', Farbe1: globals.Gewicht_normal, Farbe2: globals.Gewicht_normal_blass, Breite: EntryWidthGew,),
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

class myListRowWidget extends StatelessWidget {
  final String Titel1;
  final String Titel2;
  final Color Farbe1;
  final Color? Farbe2;
  final double Breite;
  const myListRowWidget({
    Key? key,required this.Titel1, required this.Titel2, required this.Farbe1, required this.Farbe2, required this.Breite
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: this.Breite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(this.Titel1, textScaleFactor: 1.0,),
              Text(this.Titel2, textScaleFactor: 1.0,),
            ],
          ),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  width: 0.0,
                  color: globals.BgColorNeutral
              ),
              left: BorderSide(
                  width: 0.0,
                  color: globals.BgColorNeutral
              ),
              right: BorderSide(
                  width: 0.0,
                  color: globals.BgColorNeutral
              ),
              bottom: BorderSide(
                width: 3.0,
                color: this.Farbe1
              )
            ),
            color: this.Farbe2,
          ),
        ),
      ],
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
  const _url =
      'mailto:claus@clausjbauer.de?subject=[SysDiaPulsGew]&body=Hier bitte den Text an den Autor ergänzen...';
  if (await canLaunch(_url)) {
    await launch(_url);
  } else {
    throw 'Fehler beim Aufruf von $_url';
  }
}
