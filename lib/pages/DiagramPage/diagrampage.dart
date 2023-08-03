import '../../my-globals.dart' as globals;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../InfoPage/infopage.dart';
import 'package:sysdiapulsgew/services/screenhelper.dart';
import 'package:intl/intl.dart';

class diagramPage extends StatefulWidget {
  const diagramPage({Key? key}) : super(key: key);

  @override
  State<diagramPage> createState() => _diagramPageState();
}

class ChartData {
  ChartData( this.x, this.y_Sys, this.y_Dia );
  final DateTime x;
  final int y_Sys;
  final int y_Dia;
  int ySys() => y_Sys;
  int yDia() => y_Dia;
}

double _currentSliderValue_DiagramDaysCount = 7;
bool _isLoading = true;
int anzTage = 14;
int flexChart = 14;
// double _Faktor = 0.0;
late ChartData _minSysData;
late ChartData _maxSysData;
late ChartData _minDiaData;
late ChartData _maxDiaData;
class _diagramPageState extends State<diagramPage> {

  List<ChartData> chartData = [];
  
  _ladeDaten() async {
    anzTage = await dbHelper.getDiagramDaysCount();
    _currentSliderValue_DiagramDaysCount = anzTage.toDouble();
    chartData = await dbHelper.getWertFuerDiagramm("Systole", "Diastole", -anzTage);
    if ( chartData.length > 0 ) {
      _minSysData = chartData.reduce((item1, item2) {
        return item1.y_Sys < item2.y_Sys ? item1 : item2;
      });
      _maxSysData = chartData.reduce((item1, item2) {
        return item1.y_Sys > item2.y_Sys ? item1 : item2;
      });
      _minDiaData = chartData.reduce((item1, item2) {
        return item1.y_Dia < item2.y_Dia ? item1 : item2;
      });
      _maxDiaData = chartData.reduce((item1, item2) {
        return item1.y_Dia > item2.y_Dia ? item1 : item2;
      });
    }
    print("${_minSysData.y_Sys} / ${_maxSysData.y_Sys} / ${_minSysData.y_Dia} / ${_maxSysData.y_Dia} // ${_minDiaData.y_Sys} / ${_maxDiaData.y_Sys} / ${_minDiaData.y_Dia} / ${_maxDiaData.y_Dia}");
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _ladeDaten();
  }
  @override
  Widget build(BuildContext context) {
    bool isLandscape = Screen.isLandscape(context);
    // bool isLargePhone = Screen.diagonal(context) > 720;
    // bool isNarrow = Screen.widthInches(context) < 3.5;
    bool isTablet = Screen.diagonalInches(context) >= 8.5; // war 7s
    // isTablet ? _Faktor = 0.9 : _Faktor = 0.8;

    return SafeArea(
      child: Scaffold(
        // Header
        // ------
        appBar: AppBar(
          backgroundColor: globals.CardColor,
          elevation: 4.0,
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
            // IconButton(
            //   icon: const Icon(Icons.settings_sharp),
            //   onPressed: () {
            //     //Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       PageTransition(
            //         child: const SettingsPage(),
            //         alignment: Alignment.topCenter,
            //         type: PageTransitionType.leftToRightWithFade,),
            //     );
            //   },
            // ),
          ],
        ),
        // Body
        // ----
        body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            Flexible(
              flex: 2,
              child: Container(
                width: Screen.width(context),
                color: globals.CardColor,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 12.0, right: 8.0, bottom: 8.0,),
                  child: Text('Tages-Blutdruckverteilung\nSystole (cyan) - Diastole (blaugrau)',
                    textScaleFactor: 1.25,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            chartData.length > 0 ? Flexible(
              flex: flexChart,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0,),
                child: SfCartesianChart(
                  // title: ChartTitle(
                  //   text: 'Tages-Blutdruckverteilung\nSystole (cyan) - Diastole (blaugrau)\nüber $anzTage Tage'
                  // ),
                  primaryXAxis: DateTimeAxis(
                    minimum: DateTime(2000,1,1,0,0),
                    maximum: DateTime(2000,1,1,24,0),
                    intervalType: DateTimeIntervalType.hours,
                    interval: 2,
                    dateFormat: DateFormat.Hm(),
                    title: AxisTitle(
                        text: "Tageszeit"
                    ),
                    plotBands: <PlotBand>[
                      PlotBand(
                        isVisible: _minSysData.y_Sys < 120 && _maxDiaData.y_Dia < 100,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Sys,
                        associatedAxisStart: 110,
                        associatedAxisEnd: 120,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_optimal_schwach,
                        // text: 'optimal',
                        // textAngle: 0.0,
                        // textStyle: TextStyle(color: Colors.black, fontSize: 12.0),
                        // horizontalTextAlignment: TextAnchor.start,
                        // verticalTextAlignment: TextAnchor.middle,
                      ),
                      PlotBand(
                        isVisible: _maxSysData.y_Sys >= 120,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Sys,
                        associatedAxisStart: 120,
                        associatedAxisEnd: 130,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_normal_schwach,
                      ),
                      PlotBand(
                        isVisible: _maxSysData.y_Sys >= 130,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Sys,
                        associatedAxisStart: 130,
                        associatedAxisEnd: 140,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_hochnormal_schwach,
                      ),
                      PlotBand(
                        isVisible: _maxSysData.y_Sys >= 140,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Sys,
                        associatedAxisStart: 140,
                        associatedAxisEnd: 160,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_Stufe_1_schwach,
                      ),
                      PlotBand(
                        isVisible: _maxSysData.y_Sys >= 160,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Sys,
                        associatedAxisStart: 160,
                        associatedAxisEnd: 180,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_Stufe_2_schwach,
                      ),
                      PlotBand(
                        isVisible: _maxSysData.y_Sys >= 180,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Sys,
                        associatedAxisStart: 180,
                        associatedAxisEnd: 200,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_Stufe_3_schwach,
                      ),


                      PlotBand(
                        isVisible: _minDiaData.y_Dia < 80,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Dia,
                        associatedAxisStart: 65,
                        associatedAxisEnd: 80,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_optimal_schwach,
                      ),
                      PlotBand(
                        isVisible: _maxDiaData.y_Dia >= 80,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Dia,
                        associatedAxisStart: 80,
                        associatedAxisEnd: 85,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_normal_schwach,
                      ),
                      PlotBand(
                        isVisible: _maxDiaData.y_Dia >= 85,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Dia,
                        associatedAxisStart: 85,
                        associatedAxisEnd: 90,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_hochnormal_schwach,
                      ),
                      PlotBand(
                        isVisible: _maxDiaData.y_Dia >= 90,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Dia,
                        associatedAxisStart: 90,
                        associatedAxisEnd: 100,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_Stufe_1_schwach,
                      ),
                      PlotBand(
                        isVisible: _maxDiaData.y_Dia >= 100,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Dia,
                        associatedAxisStart: 100,
                        associatedAxisEnd: 110,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_Stufe_2_schwach,
                      ),
                      PlotBand(
                        isVisible: _maxDiaData.y_Dia >= 110 && _minSysData.y_Sys > 110,
                        start: DateTime.now(),
                        end: chartData[chartData.length-1].y_Dia,
                        associatedAxisStart: 110,
                        associatedAxisEnd: 120,
                        shouldRenderAboveSeries: false,
                        color: globals.SysDia_Stufe_1_schwach,
                      ),
                    ],
                  ),
                  primaryYAxis: NumericAxis(
                    interval: 10.0,
                    title: AxisTitle(
                      text: "mmHg"
                    ),
                  ),
                  series: <CartesianSeries<ChartData, DateTime>>[
                    ScatterSeries<ChartData, DateTime>(
                      color: Colors.cyan[300],
                      dataSource: chartData,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y_Sys
                    ),
                    ScatterSeries<ChartData, DateTime>(
                      color: Colors.blueGrey[300],
                      dataSource: chartData,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y_Dia
                    ),
                  ],
                ),
              ),
            ) : Flexible(flex: flexChart, child: Center(child: Text('keine Daten'))),
            Flexible(
                flex: 2,
                child: Container(
                  color: globals.CardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 10,
                          child: Slider(
                            value: _currentSliderValue_DiagramDaysCount,
                            min: 7,
                            max: 91,
                            divisions: 12,
                            onChanged: (double value) async {
                              print(value);
                              _isLoading = true;
                              await dbHelper.setDiagramDaysCount(value.toInt());
                              await _ladeDaten();
                            },),
                        ),
                        Flexible(
                          flex: 2,
                          child: Text("${_currentSliderValue_DiagramDaysCount.round()} Tage",
                            textScaleFactor: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    color: globals.SysDia_optimal_schwach,
                    width: Screen.width(context) / 6,
                    height: 50.0,
                    alignment: Alignment.center,
                    child: const Text(
                      "optimal",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    color: globals.SysDia_normal_schwach,
                    width: Screen.width(context) / 6,
                    height: 50.0,
                    alignment: Alignment.center,
                    child: const Text(
                      "normal",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    color: globals.SysDia_hochnormal_schwach,
                    width: Screen.width(context) / 6,
                    height: 50.0,
                    alignment: Alignment.center,
                    child: const Text(
                      "hoch-normal",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    color: globals.SysDia_Stufe_1_schwach,
                    width: Screen.width(context) / 6,
                    height: 50.0,
                    alignment: Alignment.center,
                    child: const Text(
                      "Stufe 1",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    color: globals.SysDia_Stufe_2_schwach,
                    width: Screen.width(context) / 6,
                    height: 50.0,
                    alignment: Alignment.center,
                    child: const Text(
                      "Stufe 2",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    color: globals.SysDia_Stufe_3_schwach,
                    width: Screen.width(context) / 6,
                    height: 50.0,
                    alignment: Alignment.center,
                    child: const Text(
                      "Stufe 3",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}
