import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
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
  LineChartPage(this.data, this.fullName, {Key? key}) : super(key: key){
    data.sort((value1, value2) {
      return value1.date.millisecondsSinceEpoch - value2.date.millisecondsSinceEpoch;
    });
  }

  final List<BloodPressure> data;
  final String fullName;

  @override
  _LineChartPageState createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> {
  late DateTime minDisplayTime;
  late DateTime maxDisplayTime;
  final redTriangle = MarkerSettings(shape: DataMarkerType.triangle, borderColor: Colors.red, color: Colors.red, isVisible: true, width: 10);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.data.isNotEmpty){
      minDisplayTime = widget.data.first.date;
      maxDisplayTime = widget.data.last.date;
    }
    else{
      minDisplayTime = DateTime.now();
      maxDisplayTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yy', "th");
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.fullName),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                TextButton(child: Text(dateFormatter.format(minDisplayTime)), onPressed: () async {
                  final chosenDate = await showDatePicker(
                    context: context,
                    locale: const Locale("th", "TH"),
                    initialDate: minDisplayTime,
                    initialDatePickerMode: DatePickerMode.day,
                    firstDate: widget.data.first.date,
                    lastDate: widget.data.last.date,
                  );
                  if (chosenDate != null){
                    setState(() {
                      minDisplayTime = chosenDate;
                    });
                  }
                },),
                Text('-'),
                TextButton(child: Text(dateFormatter.format(maxDisplayTime)), onPressed: () async {
                  final chosenDate = await showDatePicker(
                    context: context,
                    locale: const Locale("th", "TH"),
                    initialDate: maxDisplayTime,
                    initialDatePickerMode: DatePickerMode.day,
                    firstDate: widget.data.first.date,
                    lastDate: widget.data.last.date,
                  );
                  if (chosenDate != null){
                    setState(() {
                      maxDisplayTime = chosenDate;
                    });
                  }
                },),
              ],
              mainAxisSize: MainAxisSize.min,
            ),
          ),
          //Initialize the chart widget
          SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                minimum: minDisplayTime,
                maximum: maxDisplayTime,
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
                    dataLabelSettings: DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.inside),),
                LineSeries<BloodPressure, DateTime>(
                    dataSource: widget.data,
                    xValueMapper: (BloodPressure value, _) => value.date,
                    yValueMapper: (BloodPressure value, _) => value.systolic,
                    name: 'Systolic',
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.inside, ))
              ]),
        ],
        crossAxisAlignment: CrossAxisAlignment.end,));
  }
}
