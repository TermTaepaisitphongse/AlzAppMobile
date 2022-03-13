import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

// #docregion MyApp
class MyApp extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    var p1 = Temperature(date: DateTime.now().subtract(Duration(days: 1)), temperature: 121);
    var p2 = Temperature(date: DateTime.now(), temperature: 106);
    var p3 = Temperature(date: DateTime.now().subtract(Duration(days: 3)), temperature: 97);
    var p4 = Temperature(date: DateTime.now().subtract(Duration(days: 3)), temperature: 116);
    return MaterialApp(
      title: 'AlzApp - Temperature',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: TemperaturePage(temperatureRecords: [p1,p2,p3,p4], onTemperatureRecordUpdated: (records){print(records);},),
    );
  }
// #enddocregion build
}

class TemperaturePage extends StatefulWidget {
  Function onTemperatureRecordUpdated;
  final List<Temperature> temperatureRecords;

  TemperaturePage({required this.temperatureRecords, required this.onTemperatureRecordUpdated});
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('อุณหภูมิร่างกาย'),
      ),
      body: Container(child: _buildRecordList(), color: Color(0xffF3F3F3)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showDialog(context),
      ),
    );
  }

  Widget _buildRecordList() {
    Map<String, List<Temperature>> dateMap = HashMap();
    final list = widget.temperatureRecords;
    list.sort((record1, record2) {
      if (record1.date.year == record2.date.year && record1.date.month == record2.date.month && record1.date.day == record2.date.day) {
        return record1.date.millisecondsSinceEpoch - record2.date.millisecondsSinceEpoch;
      }
      return record2.date.millisecondsSinceEpoch - record1.date.millisecondsSinceEpoch;
    });
    list.forEach((element) {
      final formatter = DateFormat("dd MMM yyyy");
      final dateString = formatter.format(element.date);
      if(dateMap[dateString] != null) {
        dateMap[dateString]?.add(element);
      }
      else{
        dateMap[dateString] = [element];
      }
      });
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
                child: Text(dateMap.keys.toList()[i]),
              ),
              Flexible(
                child: ListView.builder(itemBuilder: (context, index){
                  final record = dateMap[dateMap.keys.toList()[i]]?[index];
                  var iconCheck = null;
                  var iconColor = null;
                  var tooltipMessage = null;
                  if(record!.temperature > 38.5){
                    iconCheck = Icons.warning_rounded;
                    iconColor = Colors.red;
                    tooltipMessage = "ควรไปพบแพทย์";
                  }
                  else if(record.temperature > 37.5){
                    iconCheck = Icons.arrow_circle_up_sharp;
                    iconColor = Colors.red;
                    tooltipMessage = "ค่าสูงกว่าที่คาดหมาย";
                  }
                  else if (record.temperature > 36){
                    iconCheck = Icons.check_circle;
                    iconColor = Colors.green;
                    tooltipMessage = "ค่าปกติที่คาดหมาย";
                  }
                  else if (record.temperature > 35.5) {
                    iconCheck = Icons.arrow_circle_down_sharp;
                    iconColor = Colors.red;
                    tooltipMessage = "ค่าต่ำกว่าที่คาดหมาย";
                  }
                  else {
                    iconCheck = Icons.warning_rounded;
                    iconColor = Colors.red;
                    tooltipMessage = "ควรไปพบแพทย์";
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
                    key: ValueKey<Temperature>(widget.temperatureRecords[i]),
                    onDismissed: (left) {
                      setState(() {
                        widget.temperatureRecords.removeAt(i);
                        widget.onTemperatureRecordUpdated(widget.temperatureRecords);
                      });
                    }
                  );
                },
                itemCount: dateMap[dateMap.keys.toList()[i]]?.length,
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
    String formattedDate = DateFormat('dd MMM').format(selectedDate);
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
                      Expanded(child: Text("อุณหภูมิร่างกาย", style: TextStyle(fontSize: 12.0),)),
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
                                final chosenDate = await showDatePicker(
                                    context: context,
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
              Text("อุณหภูมิร่างกาย", style: TextStyle(fontWeight: FontWeight.bold,),),
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
                errorMessage = "กรุณาระบุเวลาที่ถูกต้อง";
              });
            }
            else if (temperature > 0) {
              widget.onRecordAdded(Temperature(date: dateTime, temperature: temperature));
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