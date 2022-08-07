import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'lineChartPage.dart';

class PulsePage extends StatefulWidget {
  Function onPulseRecordUpdated;
  final List<Pulse> pulseRecords;
  String fullName;

  PulsePage({required this.fullName, required this.pulseRecords, required this.onPulseRecordUpdated});
  @override
  _PulsePageState createState() => _PulsePageState();
}

class _PulsePageState extends State<PulsePage> {

  @override
  Widget build(BuildContext context) {
    final emptyWidget = Center(child: Column(children: [
      Text("กรุณาเพิ่มรายการใหม่", style: TextStyle(color: CupertinoColors.systemGrey2)),
      SizedBox(height: 6),
      Icon(Icons.add, color: CupertinoColors.systemGrey2),
    ],
      mainAxisSize: MainAxisSize.min,));
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.fullName),
        actions: [IconButton(onPressed: (){
          final minimum = widget.pulseRecords.fold<num>(double.infinity, (previousValue, element) => element.pulse < previousValue ? element.pulse : previousValue
          );
          final maximum = widget.pulseRecords.fold<num>(0, (previousValue, element) => element.pulse > previousValue ? element.pulse : previousValue
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LineChartPage(widget.pulseRecords, widget.fullName, "ชีพจร (bpm)", maximum: maximum.toDouble(),
                    minimum: minimum.toDouble(), series: <ChartSeries<Pulse, DateTime>>[
                    LineSeries<Pulse, DateTime>(
                      dataSource: widget.pulseRecords,
                      xValueMapper: (Pulse value, _) => value.date,
                      yValueMapper: (Pulse value, _) => value.pulse,
                      name: 'ชีพจร',
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
              child: Center(child: Text('ชีพจร (bpm)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
            ),
          ),
          Expanded(child: Container(child: widget.pulseRecords.isEmpty ? GestureDetector(child: emptyWidget, onTap: () => _showDialog(context)) : _buildRecordList(), color: Color(0xffF3F3F3))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showDialog(context),
      ),
    );
  }

  Widget _buildRecordList() {
    Map<DateTime, List<Pulse>> dateMap = HashMap();
    final list = widget.pulseRecords;
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
                  if(record!.pulse >= 101){
                    iconCheck = Icons.warning_rounded;
                    iconColor = Colors.red;
                    tooltipMessage = "ควรไปพบแพทย์ทันที";
                  }
                  else if(record.pulse > 90){
                    iconCheck = Icons.arrow_circle_up_sharp;
                    iconColor = Colors.red;
                    tooltipMessage = "ควรสังเกตอาการ";
                  }
                  else if (record.pulse > 70){
                    iconCheck = Icons.check_circle;
                    iconColor = Colors.green;
                    tooltipMessage = "ค่าปกติที่คาดหมาย";
                  }
                  else if (record.pulse > 60) {
                    iconCheck = Icons.arrow_circle_down_sharp;
                    iconColor = Colors.red;
                    tooltipMessage = "ควรสังเกตอาการ";
                  }
                  else {
                    iconCheck = Icons.warning_rounded;
                    iconColor = Colors.red;
                    tooltipMessage = "ควรไปพบแพทย์ทันที";
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
                            child: Text('${record.pulse}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
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
                              title: Text("ยืนยันลบข้อมูล?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text("ไม่ลบ")),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text("ลบ"))
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (left) {
                        setState(() {
                          final index = widget.pulseRecords.indexOf(record);
                          // widget.pulseRecords.removeAt(index);
                          widget
                              .onPulseRecordUpdated(widget.pulseRecords);
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
            widget.pulseRecords.add(newRecord);
            widget.onPulseRecordUpdated(widget.pulseRecords);
          });
        });
      },
    );
  }

  _PulsePageState();
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
  int pulse = 0;
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm').format(DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute));
    String formattedDate = DateFormat('dd MMM', "th").format(selectedDate);
    print(DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute));
    return AlertDialog(
      title: new Text("บันทึกใหม่"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: <Widget>[
              Text("ประเภท", style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: Text("ชีพจร", style: TextStyle(fontSize: 12.0),)),
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
                        Text("วันที่", style: TextStyle(fontWeight: FontWeight.bold,),),
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
                                  locale: const Locale("th", "TH"),
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
                        Text("เวลา", style: TextStyle(fontWeight: FontWeight.bold),),
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
              Text("ชีพจร", style: TextStyle(fontWeight: FontWeight.bold,),),
              SizedBox(height: 4.0,),
              Row(
                children: [
                  Container(
                    width: 64,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'pulse',
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
                        pulse = int.parse(input);
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  SizedBox(width: 4,),
                  Column(
                    children: [
                      SizedBox(height: 10,),
                      Text('bpm', style: TextStyle(fontWeight: FontWeight.w100, fontSize: 12)),
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
                errorMessage = "กรุณาระบุเวลาที่ถูกต้อง";
              });
            }
            else if (pulse > 0) {
              widget.onRecordAdded(Pulse(date: dateTime, pulse: pulse));
              Navigator.pop(context);
            }
            else {
              //show red text that says invalid value
              setState(() {
                errorMessage = "กรุณากรอกค่าค่ี่ถูกต้อง";
              });
            }
          }, child: Text("เพิ่ม"),
        ),
      ],
    );
  }
}


class Pulse {
  Pulse(
      {required this.date, required this.pulse});

  final DateTime date;
  final int pulse;

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['date'] = date.millisecondsSinceEpoch;
    data['pulse'] = pulse;
    return data;
  }

  static Pulse fromJson(Map<String, dynamic> json) {
    int date = json['date'];
    int pulse = json['pulse'];
    print("json = $json");
    final record = Pulse(
        date: DateTime.fromMillisecondsSinceEpoch(date),
        pulse: pulse,
    );
    return record;
  }

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}