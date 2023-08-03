import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sysdiapulsgew/services/dbhelper.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../model/model.dart';
import '../../my-globals.dart' as globals;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = true;
  int _TableEntryCount = 25;
  double _currentSliderValue_TabEntryCount = 20;
  bool _hasChanged = false;

  double _Koerpergroesse = 181.0;
  double minimumLevel = 0.0;
  double maximumLevel = 220.0;

  /// Holds the SampleModel information
  late SampleModel model;

  /// Holds the information of current page is card view or not
  late bool isCardView;

  void _ladeDaten() async {
    _TableEntryCount = await dbHelper.getTabEntryCount();
    _currentSliderValue_TabEntryCount = _TableEntryCount.toDouble();
    _Koerpergroesse = await dbHelper.getGroesse();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _doSpeichern() async {
    bool erfolgreich = false;
    try {
      await dbHelper.setTabEntryCount(_currentSliderValue_TabEntryCount.toInt());
      await dbHelper.setGroesse(_Koerpergroesse.toDouble());
      globals.gGroesse = _Koerpergroesse;
      erfolgreich = true;
    } on Error catch (_, e) {
      if (kDebugMode) {
        print("Fehler in _doSpeichern(): $e");
      }
      erfolgreich = true;
    }
    if (erfolgreich == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Änderungen gespeichert.'),
          backgroundColor: Colors.green));
      // kehrt zur Liste der Einträge zurück
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    model = SampleModel.instance;
    isCardView = model.isCardView && !model.isWebFullView;
    super.initState();
    _ladeDaten();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: globals.CardColor,
        elevation: 4.0,
        title: const Text("Einstellungen"),
        actions: [
          Visibility(
            visible: _hasChanged,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () async {
                  _doSpeichern();
                },
                child: Row(
                  children: [
                    const Text('übernehmen'),
                    Icon(MdiIcons.checkBold),
                  ],
                )),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 25, horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Anzahl sichtbarer Einträge in der Liste",
                      textScaleFactor: 1.3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 10,
                          child: Slider(
                              value: _currentSliderValue_TabEntryCount,
                              min: 5,
                              max: 100,
                              divisions: 19,
                              label: _currentSliderValue_TabEntryCount
                                  .round()
                                  .toString(),
                              onChanged: (double value) {
                                setState(() {
                                  _currentSliderValue_TabEntryCount = value;
                                  _hasChanged = true;
                                });
                              }),
                        ),
                        Flexible(
                            flex: 1,
                            child: Text(
                                "${_currentSliderValue_TabEntryCount.round()}",
                                textScaleFactor: 1.7)),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Text(
                      "Körpergröße in cm",
                      textScaleFactor: 1.3,
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width >= 1000
                              ? 550
                              : 440,
                          height: 500,
                          child: _buildHeightCalculator(context),
                        )),
                  ],
                ),
              ),
            )),
    );
  }

  /// Returns the height calculator.
  Widget _buildHeightCalculator(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
            child: Container(
                height: isCardView
                    ? MediaQuery.of(context).size.height * 0.6
                    : MediaQuery.of(context).size.height * 3 / 4,
                padding: const EdgeInsets.all(5.0),
                child: SfLinearGauge(
                  orientation: LinearGaugeOrientation.vertical,
                  maximum: maximumLevel,
                  tickPosition: LinearElementPosition.inside,
                  labelPosition: LinearLabelPosition.inside,
                  minorTicksPerInterval: 0,
                  interval: isCardView ? 50 : 25,
                  onGenerateLabels: () {
                    return isCardView
                        ? <LinearAxisLabel>[
                            const LinearAxisLabel(text: '0 cm', value: 0),
                            const LinearAxisLabel(text: '50 cm', value: 50),
                            const LinearAxisLabel(text: '100 cm', value: 100),
                            const LinearAxisLabel(text: '150 cm', value: 150),
                            const LinearAxisLabel(text: '200 cm', value: 200),
                          ]
                        : <LinearAxisLabel>[
                            const LinearAxisLabel(text: '0 cm', value: 0),
                            const LinearAxisLabel(text: '25 cm', value: 25),
                            const LinearAxisLabel(text: '50 cm', value: 50),
                            const LinearAxisLabel(text: '75 cm', value: 75),
                            const LinearAxisLabel(text: '100 cm', value: 100),
                            const LinearAxisLabel(text: '125 cm', value: 125),
                            const LinearAxisLabel(text: '150 cm', value: 150),
                            const LinearAxisLabel(text: '175 cm', value: 175),
                            const LinearAxisLabel(text: '200 cm', value: 200),
                          ];
                  },
                  axisTrackStyle: const LinearAxisTrackStyle(),
                  markerPointers: <LinearMarkerPointer>[
                    LinearShapePointer(
                        value: _Koerpergroesse,
                        enableAnimation: false,
                        onChanged: (dynamic value) {
                          setState(() {
                            _Koerpergroesse = value as double;
                            _hasChanged = true;
                          });
                        },
                        shapeType: LinearShapePointerType.rectangle,
                        // color: const Color(0xff0074E3),
                        color: globals.CardColor,
                        height: 1.5,
                        width: isCardView ? 150 : 250),
                    LinearWidgetPointer(
                        value: _Koerpergroesse,
                        enableAnimation: false,
                        onChanged: (dynamic value) {
                          setState(() {
                            _Koerpergroesse = value as double;
                            _hasChanged = true;
                          });
                        },
                        child: SizedBox(
                            width: 24,
                            height: 16,
                            child: Image.asset(
                              'lib/assets/images/rectangle_pointer.png',
                            ))),
                    LinearWidgetPointer(
                        value: _Koerpergroesse,
                        enableAnimation: false,
                        onChanged: (dynamic value) {
                          setState(() {
                            _Koerpergroesse = value as double;
                            _hasChanged = true;
                          });
                        },
                        offset: isCardView ? 150 : 230,
                        position: LinearElementPosition.outside,
                        child: Container(
                            width: 60,
                            height: 25,
                            decoration: BoxDecoration(
                                color: model.cardColor,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: brightness == Brightness.light
                                        ? globals.CardColor
                                        : Colors.black54,
                                    offset: const Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(4)),
                            child: Center(
                              child: Text(
                                  '${_Koerpergroesse.toStringAsFixed(0)} cm',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: Color(0xff0074E3))),
                            ))),
                  ],
                  ranges: <LinearGaugeRange>[
                    LinearGaugeRange(
                      endValue: _Koerpergroesse,
                      startWidth: 200,
                      midWidth: isCardView ? 200 : 300,
                      endWidth: 200,
                      color: Colors.transparent,
                      child: Image.asset(
                        brightness == Brightness.light
                            ? 'lib/assets/images/bmi_light.png'
                            : 'lib/assets/images/bmi_dark.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ],
                ))));
  }
}
