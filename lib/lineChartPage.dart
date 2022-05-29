import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'BloodPressurePage.dart';

void main() {
  return runApp(_ChartApp());
}

class _ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LineChartPage([
        BloodPressure(date: DateTime(1, 1, 1), diastolic: 35, systolic: 35),
        BloodPressure(date: DateTime(2, 2, 2), diastolic: 40, systolic: 40),
        BloodPressure(date: DateTime(3, 3, 3), diastolic: 30, systolic: 35),
      ], "hello"),
    );
  }
}

class LineChartPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  LineChartPage(this.data, this.fullName, {Key? key}) : super(key: key);

  final List<BloodPressure> data;
  final String fullName;

  @override
  _LineChartPageState createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> {
  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yy \n HH mm', "th");
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.fullName),
        ),
        body: Column(children: [
          //Initialize the chart widget
          SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                // minimum: DateTime(DateTime.now().year, 1),
                // maximum: DateTime(DateTime.now().year, 12),
              ),
              // Chart title
              title: ChartTitle(text: 'ความดันเลือด (mmhg)'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<BloodPressure, DateTime>>[
                LineSeries<BloodPressure, DateTime>(
                    dataSource: widget.data,
                    xValueMapper: (BloodPressure value, _) => value.date,
                    yValueMapper: (BloodPressure value, _) => value.diastolic,
                    name: 'Diastolic',
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.inside)),
                LineSeries<BloodPressure, DateTime>(
                    dataSource: widget.data,
                    xValueMapper: (BloodPressure value, _) => value.date,
                    yValueMapper: (BloodPressure value, _) => value.systolic,
                    name: 'Systolic',
                    markerSettings: MarkerSettings(shape: DataMarkerType.diamond),
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.inside, ))
              ]),
        ]));
  }
}
