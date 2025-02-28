import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:easy_localization/easy_localization.dart';

import 'lineChartPage.dart';

class TemperaturePage extends StatefulWidget {
  Function onTemperatureRecordUpdated;
  final List<Temperature> temperatureRecords;
  String fullName;

  TemperaturePage({required this.fullName, required this.temperatureRecords, required this.onTemperatureRecordUpdated});
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {

  @override
  Widget build(BuildContext context) {
    final emptyWidget = Center(child: Column(children: [
      Text('add_new_patient'.tr(), style: TextStyle(color: CupertinoColors.systemGrey2)),
      SizedBox(height: 6),
      Icon(Icons.add, color: CupertinoColors.systemGrey2),
    ],
      mainAxisSize: MainAxisSize.min,));
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.fullName),
        actions: [IconButton(onPressed: (){
          final minimum = widget.temperatureRecords.fold<double>(double.infinity, (previousValue, element) => element.temperature < previousValue ? element.temperature : previousValue
          );
          final maximum = widget.temperatureRecords.fold<double>(0, (previousValue, element) => element.temperature > previousValue ? element.temperature : previousValue
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LineChartPage(widget.temperatureRecords, widget.fullName, 'temperature'.tr() + " (°C)", maximum: maximum, minimum: minimum, series: <ChartSeries<Temperature, DateTime>>[
                    LineSeries<Temperature, DateTime>(
                      dataSource: widget.temperatureRecords,
                      xValueMapper: (Temperature value, _) => value.date,
                      yValueMapper: (Temperature value, _) => value.temperature,
                      name: 'temperature'.tr(),
                      color: Colors.blueAccent,
                      markerSettings: MarkerSettings(borderWidth: 3, shape: DataMarkerType.circle, isVisible: true, color: Colors.blueAccent),
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.inside),),
                  ],)
              )
          );
        },
            icon: Icon(Icons.stacked_line_chart))],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            color: CupertinoColors.systemGrey6,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(child: Text('temperature'.tr() + " (°C)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
            ),
          ),
          Expanded(child: Container(child: widget.temperatureRecords.isEmpty ? GestureDetector(child: emptyWidget, onTap: () => _showDialog(context)) : _buildRecordList(), color: Color(0xffF3F3F3))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showDialog(context),
      ),
    );
  }

  Widget _buildRecordList() {
    Map<DateTime, List<Temperature>> dateMap = HashMap();
    final list = widget.temperatureRecords;
    list.sort((record1, record2) {
      return record2.date.millisecondsSinceEpoch - record1.date.millisecondsSinceEpoch;
    });
    final formatter = DateFormat("dd MMM yyyy", "th");
    list.forEach((element) {
      final dateString = formatter.format(element.date);
      final date = formatter.parse(dateString);
      if(dateMap[date] != null) {
        dateMap[date]?.add(element);
      }
      else{
        dateMap[date] = [element];
      }
      });
    final sortedKeys = dateMap.keys.toList();
    sortedKeys.sort();
    final reversedKeys = sortedKeys.reversed;
    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: dateMap.length,
        itemBuilder: (context, i) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 16.0, 0.0, 4.0),
                child: Text(formatter.format(reversedKeys.toList()[i])),
              ),
              Flexible(
                child: ListView.builder(itemBuilder: (context, index){
                  final record = dateMap[reversedKeys.toList()[i]]?[index];
                  var iconCheck = null;
                  var iconColor = null;
                  var tooltipMessage = null;
                  if(record!.temperature > 38.5){
                    iconCheck = Icons.warning_rounded;
                    iconColor = Colors.red;
                    tooltipMessage = 'tip_meet_doctor'.tr();
                  }
                  else if(record.temperature > 37.5){
                    iconCheck = Icons.arrow_circle_up_sharp;
                    iconColor = Colors.red;
                    tooltipMessage = 'tip_high'.tr();
                  }
                  else if (record.temperature > 36){
                    iconCheck = Icons.check_circle;
                    iconColor = Colors.green;
                    tooltipMessage = 'tip_normal'.tr();
                  }
                  else if (record.temperature > 35.5) {
                    iconCheck = Icons.arrow_circle_down_sharp;
                    iconColor = Colors.red;
                    tooltipMessage = 'tip_low'.tr();
                  }
                  else {
                    iconCheck = Icons.warning_rounded;
                    iconColor = Colors.red;
                    tooltipMessage = 'tip_meet_doctor'.tr();
                  }
                  return Dismissible(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(height: 75, child: Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Row(children: [
                          Tooltip(
                              child: Icon(iconCheck, color: iconColor),
                              message: tooltipMessage),
                          SizedBox(width: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text('${record.temperature}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          ),
                          SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Align(child: Text('°C', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal,)), alignment: Alignment.bottomLeft,),
                          ),
                          Expanded(child: Text(DateFormat('HH:mm').format(DateTime(record.date.year, record.date.month, record.date.day, record.date.hour, record.date.minute)), style: TextStyle(fontSize: 12), textAlign: TextAlign.end,)),
                          SizedBox(width: 8,),

                        ],
                        mainAxisSize: MainAxisSize.max,
                        ),
                      ),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: Colors.white),
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red, child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Icon(Icons.cancel),
                        ),
                      ],
                    ),),
                    key: UniqueKey(),
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('confirm_delete_info'.tr()),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('do_not_delete'.tr())),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text('delete'.tr()))
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (left) {
                        setState(() {
                          final index = widget.temperatureRecords.indexOf(record);
                          widget.temperatureRecords.removeAt(index);
                          widget
                              .onTemperatureRecordUpdated(widget.temperatureRecords);
                        });
                      }
                  );
                },
                itemCount: dateMap[reversedKeys.toList()[i]]?.length,
                  shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                ),
              )
            ],
          );
        });
  }
  void _showDialog(BuildContext context) {

    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return NewRecordPage((newRecord){
          setState(() {
            widget.temperatureRecords.add(newRecord);
            widget.onTemperatureRecordUpdated(widget.temperatureRecords);
          });
        });
      },
    );
  }

  _TemperaturePageState();
}

class NewRecordPage extends StatefulWidget {
  NewRecordPage(this.onRecordAdded);
  Function onRecordAdded;

  @override
  _NewRecordPageState createState() => _NewRecordPageState();
}

class _NewRecordPageState extends State<NewRecordPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  double temperature = 0;
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm').format(DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute));
    String formattedDate = DateFormat('dd MMM', "th").format(selectedDate);
    print(DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute));
    return AlertDialog(
      title: new Text('new_record'.tr()),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: <Widget>[
              Text('record_type'.tr(), style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: Text('temperature'.tr(), style: TextStyle(fontSize: 12.0),)),
                      Icon(Icons.arrow_drop_down_sharp, color: Colors.black12),
                    ],
                  ),
                ),
              ),
              SizedBox(height:8.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('date'.tr(), style: TextStyle(fontWeight: FontWeight.bold,),),
                        SizedBox(height: 4.0),
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final chosenDate = await showRoundedDatePicker(
                                  context: context,
                                  locale: context.locale,
                                  era: EraMode.BUDDHIST_YEAR,
                                  initialDate: selectedDate,
                                  initialDatePickerMode: DatePickerMode.day,
                                  firstDate: DateTime.now().subtract(Duration(days: 6*31)),
                                  lastDate: DateTime.now(),
                                );
                                if (chosenDate != null){
                                  setState(() {
                                    selectedDate = chosenDate;
                                  });
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(Icons.calendar_today, size: 18),
                                  SizedBox(width: 4.0),
                                  Expanded(child: Text(formattedDate, style: TextStyle(fontSize: 12.0),)),
                                  Icon(Icons.arrow_drop_down_sharp),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.0,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('time'.tr(), style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 4.0),
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final chosenTime = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime
                                );
                                if (chosenTime != null) {
                                  setState(() {
                                    selectedTime = chosenTime;
                                  });
                                }
                                print(selectedTime);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(Icons.timer, size: 18),
                                  SizedBox(width: 4.0),
                                  Expanded(child: Text(formattedTime, style: TextStyle(fontSize: 12.0),)),
                                  Icon(Icons.arrow_drop_down_sharp),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text('temperature'.tr(), style: TextStyle(fontWeight: FontWeight.bold,),),
              SizedBox(height: 4.0,),
              Row(
                children: [
                  Container(
                    width: 64,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'temperature',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (input) {
                        temperature = double.parse(input);
                      },
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),],
                    ),
                  ),
                  SizedBox(width: 4,),
                  Column(
                    children: [
                      SizedBox(height: 10,),
                      Text('°C', style: TextStyle(fontWeight: FontWeight.w100, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 12),),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        ElevatedButton(
          onPressed: () {
            DateTime dateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
            // Validate returns true if the form is valid, or false otherwise.
            if (dateTime.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
              setState(() {
                errorMessage = 'incorrect_time'.tr();
              });
            }
            else if (temperature > 0) {
              widget.onRecordAdded(Temperature(date: dateTime, temperature: temperature));
              Navigator.pop(context);
            }
            else {
              //show red text that says invalid value
              setState(() {
                errorMessage = 'incorrect_value'.tr();
              });
            }
          }, child: Text('add'.tr()),
        ),
      ],
    );
  }
}


class Temperature {
  Temperature(
      {required this.date, required this.temperature});

  final DateTime date;
  final double temperature;

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['date'] = date.millisecondsSinceEpoch;
    data['temperature'] = temperature;
    return data;
  }

  static Temperature fromJson(Map<String, dynamic> json) {
    int date = json['date'];
    double temperature = json['temperature'];
    print("json = $json");
    final record = Temperature(
        date: DateTime.fromMillisecondsSinceEpoch(date),
        temperature: temperature,
    );
    return record;
  }

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}