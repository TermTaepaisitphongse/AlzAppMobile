import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:easy_localization/easy_localization.dart';

class LineChartPage extends StatefulWidget {
  final String title;
  final List<dynamic> data;
  final String fullName;
  final double? minimum;
  final double? maximum;

  final dynamic series;

  // ignore: prefer_const_constructors_in_immutables
  LineChartPage(this.data, this.fullName, this.title,
      {required this.series, this.maximum, this.minimum, Key? key})
      : super(key: key) {
    data.sort((value1, value2) {
      return value1.date.millisecondsSinceEpoch -
          value2.date.millisecondsSinceEpoch;
    });
  }

  @override
  _LineChartPageState createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> {
  late DateTime minDisplayTime;
  late DateTime maxDisplayTime;
  final redTriangle = MarkerSettings(
      shape: DataMarkerType.triangle,
      borderColor: Colors.red,
      color: Colors.red,
      isVisible: true,
      width: 10);
  late GlobalKey<SfCartesianChartState> _cartesianChartKey;

  @override
  void initState() {
    super.initState();
    _cartesianChartKey = GlobalKey();
    if (widget.data.isNotEmpty) {
      minDisplayTime = widget.data.first.date;
      maxDisplayTime = widget.data.last.date;
    } else {
      minDisplayTime = DateTime.now();
      maxDisplayTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yy', "th");
    double? max = widget.maximum == double.infinity ? 0.0 : widget.maximum;
    double? min = widget.minimum == double.infinity ? 0.0 : widget.minimum;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.fullName),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    TextButton(
                      child: Text(dateFormatter.format(minDisplayTime)),
                      onPressed: () async {
                        final chosenDate = await showDatePicker(
                          context: context,
                          locale: context.locale,
                          initialDate: minDisplayTime,
                          initialDatePickerMode: DatePickerMode.day,
                          firstDate: widget.data.first.date,
                          lastDate: widget.data.last.date,
                        );
                        if (chosenDate != null) {
                          setState(() {
                            minDisplayTime = chosenDate;
                          });
                        }
                      },
                    ),
                    Text('-'),
                    TextButton(
                      child: Text(dateFormatter.format(maxDisplayTime)),
                      onPressed: () async {
                        final chosenDate = await showDatePicker(
                          context: context,
                          locale: context.locale,
                          initialDate: maxDisplayTime,
                          initialDatePickerMode: DatePickerMode.day,
                          firstDate: widget.data.first.date,
                          lastDate: widget.data.last.date,
                        );
                        if (chosenDate != null) {
                          setState(() {
                            maxDisplayTime = chosenDate.add(
                                Duration(hours: 23, minutes: 59, seconds: 59));
                          });
                        }
                      },
                    ),
                  ],
                  mainAxisSize: MainAxisSize.min,
                ),
              ),
              //Initialize the chart widget
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfCartesianChart(
                  backgroundColor: Colors.white,
                  key: _cartesianChartKey,
                  primaryXAxis: DateTimeAxis(
                    minimum: minDisplayTime,
                    maximum: maxDisplayTime,
                  ),
                  primaryYAxis: NumericAxis(
                    maximum: (max ?? 0.0) + 10.0,
                    minimum: (min ?? 0.0) - 10.0,
                  ),
                  // Chart title
                  title: ChartTitle(text: widget.title),
                  // Enable legend
                  legend:
                      Legend(isVisible: true, position: LegendPosition.bottom),
                  // Enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: widget.series,
                  zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true,
                      enablePanning: true,
                      enableDoubleTapZooming: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton(
                    onPressed: () async {
                      if (await Permission.storage.request().isGranted) {
                        await saveImage(context);
                        // Either the permission was already granted before or the user just granted it.
                      }
                    },
                    child: Text('save_image'.tr())),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.end,
          ),
        ));
  }

  Future<void> saveImage(BuildContext context) async {
    Uint8List imageBytes = await _renderChartAsImage();
    final result = await ImageGallerySaver.saveImage(imageBytes);
    if (result['isSuccess']) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('บันทึกภาพสำเร็จ'),
                actions: [
                  ElevatedButton(
                    child: Text('close'.tr()),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ));
    }
  }

  Future<Uint8List> _renderChartAsImage() async {
    final ui.Image data =
        await _cartesianChartKey.currentState!.toImage(pixelRatio: 3.0);
    final ByteData? bytes =
        await data.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes =
        bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    return imageBytes;
  }

  calculateOffsetTime(DateTime minDate, DateTime maxDate) {
    final difference = 0.05 *
        (maxDate.millisecondsSinceEpoch - minDate.millisecondsSinceEpoch);
    // return Duration(milliseconds: difference.toInt());
    return Duration(days: 0);
  }
}
