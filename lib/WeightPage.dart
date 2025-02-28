import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:easy_localization/easy_localization.dart';

import 'main.dart';
import 'lineChartPage.dart';

class WeightPage extends StatefulWidget {
  Function onWeightRecordUpdated;
  final List<Weight> weightRecords;
  Patient patient;

  WeightPage({required this.patient, required this.weightRecords, required this.onWeightRecordUpdated});
  @override
  _WeightPageState createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {

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
        title: Text(widget.patient.name),
        actions: [IconButton(onPressed: (){
          final minimum = widget.weightRecords.fold<double>(double.infinity, (previousValue, element) => element.weight < previousValue ? element.weight : previousValue
          );
          final maximum = widget.weightRecords.fold<double>(0, (previousValue, element) => element.weight > previousValue ? element.weight : previousValue
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LineChartPage(widget.weightRecords, widget.patient.name, 'weight'.tr() + " (kg)", maximum: maximum, minimum: minimum, series: <ChartSeries<Weight, DateTime>>[
                    LineSeries<Weight, DateTime>(
                      dataSource: widget.weightRecords,
                      xValueMapper: (Weight value, _) => value.date,
                      yValueMapper: (Weight value, _) => value.weight,
                      name: 'weight'.tr(),
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
              child: Center(child: Text('weight'.tr() + " (kg)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
            ),
          ),
          Container(
            width: double.infinity,
            color: CupertinoColors.systemGrey6,
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: ElevatedButton(onPressed: (){
                final bmi = widget.weightRecords.map((weight) {
                  final heightInMeters = (widget.patient.height ?? 0) / 100.0;
                  final weightRounded = double.parse((weight.weight/heightInMeters/heightInMeters).toStringAsFixed(2));
                  return Bmi(date: weight.date, value: weightRounded);
                }).toList();
                final minimum = bmi.fold<double>(double.infinity, (previousValue, element) => element.value < previousValue ? element.value : previousValue
                );
                final maximum = bmi.fold<double>(0, (previousValue, element) => element.value > previousValue ? element.value : previousValue
                );
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LineChartPage(bmi, widget.patient.name, "BMI", maximum: maximum, minimum: minimum, series: <ChartSeries<Bmi, DateTime>>[
                          LineSeries<Bmi, DateTime>(
                            dataSource: bmi,
                            xValueMapper: (Bmi value, _) => value.date,
                            yValueMapper: (Bmi value, _) => value.value,
                            name: 'BMI',
                            color: Colors.blueAccent,
                            markerSettings: MarkerSettings(borderWidth: 3, shape: DataMarkerType.circle, isVisible: true, color: Colors.blueAccent),
                            // Enable data label
                            dataLabelSettings: DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.inside),),
                        ],)
                    )
                );
              }, child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('View Your BMI'),
              )),
            ),
          ),
          Expanded(child: Container(child: widget.weightRecords.isEmpty ? GestureDetector(child: emptyWidget, onTap: () => _showDialog(context)) : _buildRecordList(), color: Color(0xffF3F3F3))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showDialog(context),
      ),
    );
  }

  Widget _buildRecordList() {
    Map<DateTime, List<Weight>> dateMap = HashMap();
    final list = widget.weightRecords;
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
                  if (record==null){
                    return Container();
                  }
                  var iconCheck = Icons.monitor_weight_rounded;
                  var iconColor = Colors.blueAccent;
                  var tooltipMessage = 'weight'.tr();
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
                              child: Text('${record.weight}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                            ),
                            SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Align(child: Text('bpm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal,)), alignment: Alignment.bottomLeft,),
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
                          final index = widget.weightRecords.indexOf(record);
                          widget.weightRecords.removeAt(index);
                          widget
                              .onWeightRecordUpdated(widget.weightRecords);
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
            widget.weightRecords.add(newRecord);
            widget.onWeightRecordUpdated(widget.weightRecords);
          });
        });
      },
    );
  }

  _WeightPageState();
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
  double weight = 0.0;
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
                      Expanded(child: Text('weight'.tr(), style: TextStyle(fontSize: 12.0),)),
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
              Text('weight'.tr(), style: TextStyle(fontWeight: FontWeight.bold,),),
              SizedBox(height: 4.0,),
              Row(
                children: [
                  Container(
                    width: 64,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'weight'.tr(),
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
                        weight = double.parse(input);
                      },
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),],
                    ),
                  ),
                  SizedBox(width: 4,),
                  Column(
                    children: [
                      SizedBox(height: 10,),
                      Text('kg', style: TextStyle(fontWeight: FontWeight.w100, fontSize: 12)),
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
            else if (weight > 0) {
              widget.onRecordAdded(Weight(date: dateTime, weight: weight));
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


class Weight {
  Weight(
      {required this.date, required this.weight});

  final DateTime date;
  final double weight;

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['date'] = date.millisecondsSinceEpoch;
    data['weight'] = weight;
    return data;
  }

  static Weight fromJson(Map<String, dynamic> json) {
    int date = json['date'];
    double weight = json['weight'];
    print("json = $json");
    final record = Weight(
      date: DateTime.fromMillisecondsSinceEpoch(date),
      weight: weight,
    );
    return record;
  }

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}

class Bmi {
  final DateTime date;
  final double value;

  Bmi({required this.date, required this.value});

}