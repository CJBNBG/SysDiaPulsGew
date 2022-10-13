import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../my-globals.dart' as globals;
import '../../services/myWidgets.dart' as myWidgets;
import 'package:sysdiapulsgew/services/dbhelper.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

const ContainerWidth = 310.0;
const PaddingWidth = 8.0;
const EntryWidthSysDia = (ContainerWidth-2.0*PaddingWidth-8.0)/3.0;
const EntryWidthGew = (ContainerWidth-2.0*PaddingWidth-8.0);
String strAnzDSe = '';
String strZeitpunkt = '?';
String strTage = '?';

String strLinkToLiga = "https://www.hochdruckliga.de/fileadmin/downloads/mitgliederbereich/downloads/broschueren/Pocket_Leitlinien_Arterielle_Hypertonie.pdf";

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
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                                child: Text(
                                  "Autor:",
                                  textScaleFactor: 1.25,
                                  style: TextStyle(
                                    //color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(0, 5.0, 0, 0),
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
                                    const Text(
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
                                    const Text(
                                      "Version: ",
                                      textScaleFactor: 1.0,
                                    ),
                                    Text(
                                      int.parse(globals.gPackageInfo.buildNumber) > 0 ? globals.gPackageInfo.version + ' (' + globals.gPackageInfo.buildNumber + ')' : globals.gPackageInfo.version, //title
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
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
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
                                const SizedBox(height: 10.0,),
                                const Text(
                                  'verwendete Farben:',
                                  textScaleFactor: 1.25,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.end,
                                //   children: [
                                //     const Text('Quelle:',
                                //       textScaleFactor: 0.8,
                                //     ),
                                //     TextButton(
                                //       onPressed: () {
                                //         // bShowPdf = true; //action
                                //       },
                                //       child: const Text(
                                //         'hier klicken', //title
                                //         textAlign: TextAlign.end, //aligment
                                //         textScaleFactor: 0.8,
                                //         style: TextStyle(
                                //           decoration: TextDecoration.underline,
                                //         ),
                                //       ),
                                //     ),
                                //     // SfPdfViewer.network(strLinkToLiga),
                                //   ],
                                // ),
                                const SizedBox(height: 20.0,),
                                const myListWidget(Titel: "Systole (mmHg):", Wert: "", ScaleFactor: 1.0),
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
                                SizedBox(height: 20.0,),
                                Container(
                                  color: Colors.black12,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 5,
                                        child: const Text('Wenn Sie die Einteilung bei der Deutschen Hochdruckliga nachlesen möchten, dann bitte...',
                                          textScaleFactor: 1.0,
                                          softWrap: true,
                                        ),
                                      ),
                                      Flexible(
                                        flex: 3,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute<dynamic>(
                                                  builder: (_) => const PDFViewerFromUrl(
                                                    url: 'https://www.hochdruckliga.de/fileadmin/downloads/mitgliederbereich/downloads/broschueren/Pocket_Leitlinien_Arterielle_Hypertonie.pdf',
                                                  ),
                                                ),
                                              ),
                                              child: const Text('hier klicken'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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

class PDFViewerFromUrl extends StatelessWidget {
  const PDFViewerFromUrl({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('durch Wischen blättern'),
      ),
      body: const PDF().fromUrl(
        url,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class PDFViewerFromAsset extends StatelessWidget {
  PDFViewerFromAsset({Key? key, required this.pdfAssetPath}) : super(key: key);
  final String pdfAssetPath;
  final Completer<PDFViewController> _pdfViewController =
  Completer<PDFViewController>();
  final StreamController<String> _pageCountController =
  StreamController<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('durch Wischen blättern'),
        actions: <Widget>[
          StreamBuilder<String>(
              stream: _pageCountController.stream,
              builder: (_, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue[900],
                      ),
                      child: Text(snapshot.data!),
                    ),
                  );
                }
                return const SizedBox();
              }),
        ],
      ),
      body: PDF(
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
        onPageChanged: (int? current, int? total) =>
            _pageCountController.add('${current! + 1} - $total'),
        onViewCreated: (PDFViewController pdfViewController) async {
          _pdfViewController.complete(pdfViewController);
          final int currentPage = await pdfViewController.getCurrentPage() ?? 0;
          final int? pageCount = await pdfViewController.getPageCount();
          _pageCountController.add('${currentPage + 1} - $pageCount');
        },
      ).fromAsset(
        pdfAssetPath,
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _pdfViewController.future,
        builder: (_, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: '-',
                  child: const Text('-'),
                  onPressed: () async {
                    final PDFViewController pdfController = snapshot.data!;
                    final int currentPage =
                        (await pdfController.getCurrentPage())! - 1;
                    if (currentPage >= 0) {
                      await pdfController.setPage(currentPage);
                    }
                  },
                ),
                FloatingActionButton(
                  heroTag: '+',
                  child: const Text('+'),
                  onPressed: () async {
                    final PDFViewController pdfController = snapshot.data!;
                    final int currentPage =
                        (await pdfController.getCurrentPage())! + 1;
                    final int numberOfPages = await pdfController.getPageCount() ?? 0;
                    if (numberOfPages > currentPage) {
                      await pdfController.setPage(currentPage);
                    }
                  },
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}