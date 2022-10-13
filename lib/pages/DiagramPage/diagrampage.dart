import '../../my-globals.dart' as globals;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import '../InfoPage/infopage.dart';
import '../SettingsPage/settingspage.dart';
import 'package:sysdiapulsgew/services/screenhelper.dart';

class diagramPage extends StatefulWidget {
  const diagramPage({Key? key}) : super(key: key);

  @override
  State<diagramPage> createState() => _diagramPageState();
}

class AxisData {
  AxisData( this.x );
  final String x;
}
class ChartData {
  ChartData( this.x, this.y_Sys, this.y_Dia );
  final String x;
  final int y_Sys;
  final int y_Dia;
  int ySys() => y_Sys;
  int yDia() => y_Dia;
}

bool _isLoading = true;
double _Faktor = 0.0;
int _selectedIndex = 0;
int anzTage = 14;
late ChartData _minSysData;
late ChartData _maxSysData;
late ChartData _minDiaData;
late ChartData _maxDiaData;
class _diagramPageState extends State<diagramPage> {

  List<AxisData> xAchse = [
    AxisData("00:00"), AxisData("01:00"), AxisData("02:00"), AxisData("03:00"), AxisData("04:00"), AxisData("05:00"),
    AxisData("06:00"), AxisData("07:00"), AxisData("08:00"), AxisData("09:00"),
    AxisData("10:00"), AxisData("11:00"), AxisData("12:00"), AxisData("13:00"), AxisData("14:00"), AxisData("15:00"),
    AxisData("16:00"), AxisData("17:00"), AxisData("18:00"), AxisData("19:00"),
    AxisData("20:00"), AxisData("21:00"), AxisData("22:00"), AxisData("23:00")
  ];
  List<ChartData> chartData = [
    // //          x       y_Sys  y_Dia
    // ChartData( "01:00", 121.5, 80.1 ),
    // ChartData( "02:00", 132.1, 81.1 ),
    // ChartData( "03:00", 131.3, 82.1 ),
    // ChartData( "04:00", 120.5, 83.1 ),
    // ChartData( "05:00", 121.5, 94.1 ),
    // ChartData( "06:00", 122.5, 85.1 ),
    // ChartData( "07:00", 123.5, 86.1 ),
    // ChartData( "08:00", 124.5, 87.1 ),
    // ChartData( "09:00", 125.5, 88.5 ),
    // ChartData( "10:00", 126.5, 89.4 ),
    // ChartData( "11:00", 127.5, 90.3 ),
    // ChartData( "12:00", 128.5, 89.1 ),
    // ChartData( "13:00", 129.5, 88.1 ),
    // ChartData( "14:00", 130.5, 87.1 ),
    // ChartData( "15:00", 129.5, 86.1 ),
    // ChartData( "16:00", 128.5, 85.1 ),
    // ChartData( "17:00", 127.5, 74.1 ),
    // ChartData( "18:00", 126.5, 83.1 ),
    // ChartData( "19:00", 125.5, 82.1 ),
    // ChartData( "20:00", 124.5, 81.1 ),
    // ChartData( "21:00", 123.5, 80.1 ),
    // ChartData( "22:00", 122.5, 80.1 ),
    // ChartData( "23:00", 121.5, 80.1 )
  ];
  
  _ladeDaten() async {
    anzTage = await dbHelper.getDiagramDaysCount();
    print(anzTage);
    chartData = await dbHelper.getWertFuerDiagramm("Systole", "Diastole", -anzTage);
    _minSysData = chartData.reduce((item1, item2) => item1.y_Sys < item2.y_Sys ? item1 : item2);
    _maxSysData = chartData.reduce((item1, item2) => item1.y_Sys > item2.y_Sys ? item1 : item2);
    _minDiaData = chartData.reduce((item1, item2) => item1.y_Dia < item2.y_Dia ? item1 : item2);
    _maxDiaData = chartData.reduce((item1, item2) => item1.y_Dia > item2.y_Dia ? item1 : item2);
    print(_minSysData.y_Sys.toString() + ' ' + _maxSysData.y_Sys.toString() + ' ' + _minDiaData.y_Dia.toString() + ' ' + _maxDiaData.y_Dia.toString());
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
            flex: 15,
            child: SfCartesianChart(
              title: ChartTitle(
                text: 'Tages-Blutdruckverteilung\nSystole (cyan) - Diastole (blaugrau)\nüber $anzTage Tage'
              ),
              primaryXAxis: CategoryAxis(
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: _maxSysData.y_Sys > 109,
                    start: "00:00",
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
                    isVisible: _maxSysData.y_Sys > 119,
                    start: "00:00",
                    end: chartData[chartData.length-1].y_Sys,
                    associatedAxisStart: 120,
                    associatedAxisEnd: 130,
                    shouldRenderAboveSeries: false,
                    color: globals.SysDia_normal_schwach,
                  ),
                  PlotBand(
                    isVisible: _maxSysData.y_Sys > 129,
                    start: "00:00",
                    end: chartData[chartData.length-1].y_Sys,
                    associatedAxisStart: 130,
                    associatedAxisEnd: 140,
                    shouldRenderAboveSeries: false,
                    color: globals.SysDia_hochnormal_schwach,
                  ),
                  PlotBand(
                    isVisible: _maxSysData.y_Sys > 139,
                    start: "00:00",
                    end: chartData[chartData.length-1].y_Sys,
                    associatedAxisStart: 140,
                    associatedAxisEnd: 150,
                    shouldRenderAboveSeries: false,
                    color: globals.SysDia_Stufe_1_schwach,
                  ),


                  PlotBand(
                    isVisible: _maxDiaData.y_Dia > 64,
                    start: "00:00",
                    end: chartData[chartData.length-1].y_Dia,
                    associatedAxisStart: 65,
                    associatedAxisEnd: 80,
                    shouldRenderAboveSeries: false,
                    color: globals.SysDia_optimal_schwach,
                  ),
                  PlotBand(
                    isVisible: _maxDiaData.y_Dia > 79,
                    start: "00:00",
                    end: chartData[chartData.length-1].y_Dia,
                    associatedAxisStart: 80,
                    associatedAxisEnd: 85,
                    shouldRenderAboveSeries: false,
                    color: globals.SysDia_normal_schwach,
                  ),
                  PlotBand(
                    isVisible: _maxDiaData.y_Dia > 84,
                    start: "00:00",
                    end: chartData[chartData.length-1].y_Dia,
                    associatedAxisStart: 85,
                    associatedAxisEnd: 90,
                    shouldRenderAboveSeries: false,
                    color: globals.SysDia_hochnormal_schwach,
                  ),
                  PlotBand(
                    isVisible: _maxDiaData.y_Dia > 89,
                    start: "00:00",
                    end: chartData[chartData.length-1].y_Dia,
                    associatedAxisStart: 90,
                    associatedAxisEnd: 100,
                    shouldRenderAboveSeries: false,
                    color: globals.SysDia_Stufe_1_schwach,
                  ),
                ],
                title: AxisTitle(
                  text: "Tageszeit"
                ),
              ),
              primaryYAxis: CategoryAxis(
                title: AxisTitle(
                    text: "mmHg"
                ),
              ),
              series: <CartesianSeries<ChartData, String>>[
                ScatterSeries<ChartData, String>(
                  color: Colors.cyan[300],
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y_Sys
                ),
                ScatterSeries<ChartData, String>(
                  color: Colors.blueGrey[300],
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y_Dia
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
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
    );
  }
}
