import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';
import '../../services/myWidgets.dart' as myWidgets;
import '../../my-globals.dart' as globals;
import './statistikdata.dart' as stats;

//bool _isLoading = true;
const iBreite = globals.CardWidth / 3.0;
const iScaleFactor = 1.2;

class StatistikPage extends StatefulWidget {
  const StatistikPage({Key? key}) : super(key: key);

  @override
  _StatistikPageState createState() {
    return _StatistikPageState();
  }
}

class _StatistikPageState extends State<StatistikPage> {
  final PageController _controller = PageController();

  final List<Widget> _list = [
    SliderBox(
        child: Column(
          children: [
            const Text("über alle Messungen", textScaleFactor: 1.7,),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Column(
                children: [
                  const SizedBox(height: 30,),
                  const Text("vormittags (06:00 - 12:00)", textScaleFactor: iScaleFactor),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Systole\n(mmHg)',
                        Titel2: stats.strSysVorm[stats.IndexAlle]['alle'],
                        Farbe1: stats.Farbe1SysVorm[stats.IndexAlle]['alle'],
                        Farbe2: stats.Farbe2SysVorm[stats.IndexAlle]['alle'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Diastole\n(mmHg)',
                        Titel2: stats.strDiaVorm[stats.IndexAlle]['alle'],
                        Farbe1: stats.Farbe1DiaVorm[stats.IndexAlle]['alle'],
                        Farbe2: stats.Farbe2DiaVorm[stats.IndexAlle]['alle'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Puls\n(bps)',
                        Titel2: stats.strPulsVorm[stats.IndexAlle]['alle'],
                        Farbe1: stats.Farbe1PulsVorm[stats.IndexAlle]['alle'],
                        Farbe2: stats.Farbe2PulsVorm[stats.IndexAlle]['alle'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  const Text("nachmittags (12:00 - 18:00)", textScaleFactor: iScaleFactor),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Systole\n(mmHg)',
                        Titel2: stats.strSysNachm[stats.IndexAlle]['alle'],
                        Farbe1: stats.Farbe1SysNachm[stats.IndexAlle]['alle'],
                        Farbe2: stats.Farbe2SysNachm[stats.IndexAlle]['alle'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Diastole\n(mmHg)',
                        Titel2: stats.strDiaNachm[stats.IndexAlle]['alle'],
                        Farbe1: stats.Farbe1DiaNachm[stats.IndexAlle]['alle'],
                        Farbe2: stats.Farbe2DiaNachm[stats.IndexAlle]['alle'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Puls\n(bps)',
                        Titel2: stats.strPulsNachm[stats.IndexAlle]['alle'],
                        Farbe1: stats.Farbe1PulsNachm[stats.IndexAlle]['alle'],
                        Farbe2: stats.Farbe2PulsNachm[stats.IndexAlle]['alle'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  const Text("abends (18:00 - 23:59)", textScaleFactor: iScaleFactor),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Systole\n(mmHg)',
                        Titel2: stats.strSysAbends[stats.IndexAlle]['alle'],
                        Farbe1: stats.Farbe1SysAbends[stats.IndexAlle]['alle'],
                        Farbe2: stats.Farbe2SysAbends[stats.IndexAlle]['alle'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Diastole\n(mmHg)',
                        Titel2: stats.strDiaAbends[stats.IndexAlle]['alle'],
                        Farbe1: stats.Farbe1DiaAbends[stats.IndexAlle]['alle'],
                        Farbe2: stats.Farbe2DiaAbends[stats.IndexAlle]['alle'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Puls\n(bps)',
                        Titel2: stats.strPulsAbends[stats.IndexAlle]['alle'],
                        Farbe1: stats.Farbe1PulsAbends[stats.IndexAlle]['alle'],
                        Farbe2: stats.Farbe2PulsAbends[stats.IndexAlle]['alle'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        )
    ),
    SliderBox(
      child: Column(
        children: [
          const Text("über die Messungen der letzten Woche", textScaleFactor: 1.7,),
          FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              children: [
                const SizedBox(height: 30,),
                const Text("vormittags (06:00 - 12:00)", textScaleFactor: iScaleFactor),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    myWidgets.myListRowWidgetTwoLines(
                      Titel1: 'Systole\n(mmHg)',
                      Titel2: stats.strSysVorm[stats.Index1W]['-7'],
                      Farbe1: stats.Farbe1SysVorm[stats.Index1W]['-7'],
                      Farbe2: stats.Farbe2SysVorm[stats.Index1W]['-7'],
                      Breite: iBreite,
                      ScaleFactor: iScaleFactor,
                      isHeader: false,
                    ),
                    myWidgets.myListRowWidgetTwoLines(
                      Titel1: 'Diastole\n(mmHg)',
                      Titel2: stats.strDiaVorm[stats.Index1W]['-7'],
                      Farbe1: stats.Farbe1DiaVorm[stats.Index1W]['-7'],
                      Farbe2: stats.Farbe2DiaVorm[stats.Index1W]['-7'],
                      Breite: iBreite,
                      ScaleFactor: iScaleFactor,
                      isHeader: false,
                    ),
                    myWidgets.myListRowWidgetTwoLines(
                      Titel1: 'Puls\n(bps)',
                      Titel2: stats.strPulsVorm[stats.Index1W]['-7'],
                      Farbe1: stats.Farbe1PulsVorm[stats.Index1W]['-7'],
                      Farbe2: stats.Farbe2PulsVorm[stats.Index1W]['-7'],
                      Breite: iBreite,
                      ScaleFactor: iScaleFactor,
                      isHeader: false,
                    ),
                  ],
                ),
                const SizedBox(height: 30,),
                const Text("nachmittags (12:00 - 18:00)", textScaleFactor: iScaleFactor),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    myWidgets.myListRowWidgetTwoLines(
                      Titel1: 'Systole\n(mmHg)',
                      Titel2: stats.strSysNachm[stats.Index1W]['-7'],
                      Farbe1: stats.Farbe1SysNachm[stats.Index1W]['-7'],
                      Farbe2: stats.Farbe2SysNachm[stats.Index1W]['-7'],
                      Breite: iBreite,
                      ScaleFactor: iScaleFactor,
                      isHeader: false,
                    ),
                    myWidgets.myListRowWidgetTwoLines(
                      Titel1: 'Diastole\n(mmHg)',
                      Titel2: stats.strDiaNachm[stats.Index1W]['-7'],
                      Farbe1: stats.Farbe1DiaNachm[stats.Index1W]['-7'],
                      Farbe2: stats.Farbe2DiaNachm[stats.Index1W]['-7'],
                      Breite: iBreite,
                      ScaleFactor: iScaleFactor,
                      isHeader: false,
                    ),
                    myWidgets.myListRowWidgetTwoLines(
                      Titel1: 'Puls\n(bps)',
                      Titel2: stats.strPulsNachm[stats.Index1W]['-7'],
                      Farbe1: stats.Farbe1PulsNachm[stats.Index1W]['-7'],
                      Farbe2: stats.Farbe2PulsNachm[stats.Index1W]['-7'],
                      Breite: iBreite,
                      ScaleFactor: iScaleFactor,
                      isHeader: false,
                    ),
                  ],
                ),
                const SizedBox(height: 30,),
                const Text("abends (18:00 - 23:59)", textScaleFactor: iScaleFactor),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    myWidgets.myListRowWidgetTwoLines(
                      Titel1: 'Systole\n(mmHg)',
                      Titel2: stats.strSysAbends[stats.Index1W]['-7'],
                      Farbe1: stats.Farbe1SysAbends[stats.Index1W]['-7'],
                      Farbe2: stats.Farbe2SysAbends[stats.Index1W]['-7'],
                      Breite: iBreite,
                      ScaleFactor: iScaleFactor,
                      isHeader: false,
                    ),
                    myWidgets.myListRowWidgetTwoLines(
                      Titel1: 'Diastole\n(mmHg)',
                      Titel2: stats.strDiaAbends[stats.Index1W]['-7'],
                      Farbe1: stats.Farbe1DiaAbends[stats.Index1W]['-7'],
                      Farbe2: stats.Farbe2DiaAbends[stats.Index1W]['-7'],
                      Breite: iBreite,
                      ScaleFactor: iScaleFactor,
                      isHeader: false,
                    ),
                    myWidgets.myListRowWidgetTwoLines(
                      Titel1: 'Puls\n(bps)',
                      Titel2: stats.strPulsAbends[stats.Index1W]['-7'],
                      Farbe1: stats.Farbe1PulsAbends[stats.Index1W]['-7'],
                      Farbe2: stats.Farbe2PulsAbends[stats.Index1W]['-7'],
                      Breite: iBreite,
                      ScaleFactor: iScaleFactor,
                      isHeader: false,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      )
    ),
    SliderBox(
        child: Column(
          children: [
            const Text("über die Messungen des letzten Monats", textScaleFactor: 1.7,),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Column(
                children: [
                  const SizedBox(height: 30,),
                  const Text("vormittags (06:00 - 12:00)", textScaleFactor: iScaleFactor),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Systole\n(mmHg)',
                        Titel2: stats.strSysVorm[stats.Index1M]['-31'],
                        Farbe1: stats.Farbe1SysVorm[stats.Index1M]['-31'],
                        Farbe2: stats.Farbe2SysVorm[stats.Index1M]['-31'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Diastole\n(mmHg)',
                        Titel2: stats.strDiaVorm[stats.Index1M]['-31'],
                        Farbe1: stats.Farbe1DiaVorm[stats.Index1M]['-31'],
                        Farbe2: stats.Farbe2DiaVorm[stats.Index1M]['-31'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Puls\n(bps)',
                        Titel2: stats.strPulsVorm[stats.Index1M]['-31'],
                        Farbe1: stats.Farbe1PulsVorm[stats.Index1M]['-31'],
                        Farbe2: stats.Farbe2PulsVorm[stats.Index1M]['-31'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  const Text("nachmittags (12:00 - 18:00)", textScaleFactor: iScaleFactor),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Systole\n(mmHg)',
                        Titel2: stats.strSysNachm[stats.Index1M]['-31'],
                        Farbe1: stats.Farbe1SysNachm[stats.Index1M]['-31'],
                        Farbe2: stats.Farbe2SysNachm[stats.Index1M]['-31'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Diastole\n(mmHg)',
                        Titel2: stats.strDiaNachm[stats.Index1M]['-31'],
                        Farbe1: stats.Farbe1DiaNachm[stats.Index1M]['-31'],
                        Farbe2: stats.Farbe2DiaNachm[stats.Index1M]['-31'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Puls\n(bps)',
                        Titel2: stats.strPulsNachm[stats.Index1M]['-31'],
                        Farbe1: stats.Farbe1PulsNachm[stats.Index1M]['-31'],
                        Farbe2: stats.Farbe2PulsNachm[stats.Index1M]['-31'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30,),
                  const Text("abends (18:00 - 23:59)", textScaleFactor: iScaleFactor),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Systole\n(mmHg)',
                        Titel2: stats.strSysAbends[stats.Index1M]['-31'],
                        Farbe1: stats.Farbe1SysAbends[stats.Index1M]['-31'],
                        Farbe2: stats.Farbe2SysAbends[stats.Index1M]['-31'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Diastole\n(mmHg)',
                        Titel2: stats.strDiaAbends[stats.Index1M]['-31'],
                        Farbe1: stats.Farbe1DiaAbends[stats.Index1M]['-31'],
                        Farbe2: stats.Farbe2DiaAbends[stats.Index1M]['-31'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                      myWidgets.myListRowWidgetTwoLines(
                        Titel1: 'Puls\n(bps)',
                        Titel2: stats.strPulsAbends[stats.Index1M]['-31'],
                        Farbe1: stats.Farbe1PulsAbends[stats.Index1M]['-31'],
                        Farbe2: stats.Farbe2PulsAbends[stats.Index1M]['-31'],
                        Breite: iBreite,
                        ScaleFactor: iScaleFactor,
                        isHeader: false,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        )
    ),
  ];

  @override
  void initState() {
    super.initState();
    stats.ladeDaten();
  }

  @override
  Widget build(BuildContext context) {
    PageIndicatorContainer container = PageIndicatorContainer(
      child: PageView(
        controller: _controller,
        children: _list,
      ),
      length: _list.length,
      padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
      indicatorSpace: 10,
      indicatorColor: Colors.grey,
      indicatorSelectorColor: Colors.blue,
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Statistik"),
        ),
        body: /*_isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : */Stack(
          children: <Widget>[
            Container(color: Colors.grey[100], height: double.infinity),
            Container(color: globals.BgColorNeutral, child: container, margin: const EdgeInsets.only(bottom: 50)),
          ],
        ),
      ),
    );
  }
}

class SliderBox extends StatelessWidget {
  final Widget child;
  const SliderBox({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(10), child: child);
  }
}