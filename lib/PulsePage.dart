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
    var p1 = Pulse(date: DateTime.now().subtract(Duration(days: 1)), pulse: 121);
    var p2 = Pulse(date: DateTime.now(), pulse: 106);
    var p3 = Pulse(date: DateTime.now().subtract(Duration(days: 3)), pulse: 97);
    var p4 = Pulse(date: DateTime.now().subtract(Duration(days: 3)), pulse: 116);
    return MaterialApp(
      title: 'AlzApp - Pulse',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: PulsePage(pulseRecords: [p1,p2,p3,p4], onPulseRecordUpdated: (records){print(records);},),
    );
  }
// #enddocregion build
}

class PulsePage extends StatefulWidget {
  Function onPulseRecordUpdated;
  final List<Pulse> pulseRecords;

  PulsePage({required this.pulseRecords, required this.onPulseRecordUpdated});
  @override
  _PulsePageState createState() => _PulsePageState();
}

class _PulsePageState extends State<PulsePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Pulse'),
      ),
      body: Container(child: _buildRecordList(), color: Color(0xffF3F3F3)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showDialog(context),
      ),
    );
  }

  Widget _buildRecordList() {
    Map<String, List<Pulse>> dateMap = HashMap();
    final list = widget.pulseRecords;
    list.sort((record1, record2) {
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
                  if(record!.pulse > 120){
                    iconCheck = Icons.arrow_circle_up_sharp;
                    iconColor = Colors.red;
                  }
                  else if(record.pulse < 100){
                    iconCheck = Icons.arrow_circle_down_sharp;
                    iconColor = Colors.red;
                  }
                  else {
                    iconCheck = Icons.check_circle;
                    iconColor = Colors.green;
                  }
                  return Dismissible(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(height: 100, child: Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Row(children: [
                          Icon(iconCheck, color: iconColor),
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
                          Expanded(child: Text('${record.date.hour}:${record.date.minute}', style: TextStyle(fontSize: 12), textAlign: TextAlign.end,)),
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
                    key: ValueKey<Pulse>(widget.pulseRecords[i]),
                    onDismissed: (left) {
                      setState(() {
                        widget.pulseRecords.removeAt(i);
                        widget.onPulseRecordUpdated(widget.pulseRecords);
                      });
                    }
                  );
                },
                itemCount: dateMap[dateMap.keys.toList()[i]]?.length,
                  shrinkWrap: true,
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
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm').format(DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute));
    String formattedDate = DateFormat('dd/MM').format(selectedDate);
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
                                final chosenDate = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    initialDatePickerMode: DatePickerMode.day,
                                    firstDate: DateTime.now().subtract(Duration(days: 6*31)),
                                    lastDate: DateTime.now().add(Duration(days: 6*31)),
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
            // Validate returns true if the form is valid, or false otherwise.
            if (_formKey.currentState!.validate()) {
              DateTime dateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
              widget.onRecordAdded(Pulse(date: dateTime, pulse: pulse));
              Navigator.pop(context);
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