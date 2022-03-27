import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:intl/intl.dart';

class BladderBowelPage extends StatefulWidget {
  Function onBladderBowelRecordUpdated;
  final List<BladderBowel> bladderBowelRecords;
  String fullName;

  BladderBowelPage({required this.fullName, required this.bladderBowelRecords, required this.onBladderBowelRecordUpdated});
  @override
  _BladderBowelPageState createState() => _BladderBowelPageState();
}

class _BladderBowelPageState extends State<BladderBowelPage> {

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
              child: Center(child: Text('ถ่ายและฉี่ ()', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
            ),
          ),
          Expanded(child: Container(child: widget.bladderBowelRecords.isEmpty ? GestureDetector(child: emptyWidget, onTap: () => _showDialog(context)) : _buildRecordList(), color: Color(0xffF3F3F3))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showDialog(context),
      ),
    );
  }

  Widget _buildRecordList() {
    Map<DateTime, List<BladderBowel>> dateMap = HashMap();
    final list = widget.bladderBowelRecords;
    list.sort((record1, record2) {
      if (record1.date.year == record2.date.year && record1.date.month == record2.date.month && record1.date.day == record2.date.day) {
        return record1.date.millisecondsSinceEpoch - record2.date.millisecondsSinceEpoch;
      }
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
                  if(record!.bowel > 140 && record.bladder > 140){
                    iconCheck = Icons.warning_rounded;
                    iconColor = Colors.red;
                    tooltipMessage = "ควรไปพบแพทย์";
                  }
                  else if(record.bowel > 120 && record.bladder > 120){
                    iconCheck = Icons.arrow_circle_up_sharp;
                    iconColor = Colors.red;
                    tooltipMessage = "ค่าสูงกว่าที่คาดหมาย";
                  }
                  else if (record.bowel > 100 && record.bladder > 100){
                    iconCheck = Icons.check_circle;
                    iconColor = Colors.green;
                    tooltipMessage = "ค่าปกติที่คาดหมาย";
                  }
                  else if (record.bowel > 80 && record.bladder > 80) {
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
                            child: Text('${record.bowel}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          ),
                          SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Align(child: Text('ถ่าย', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal,)), alignment: Alignment.bottomLeft,),
                          ),
                          SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text('${record.bladder}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                          ),
                          SizedBox(width: 8),
                          Text('ฉี่', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal,)),
                          Expanded(child: Text(DateFormat('HH:mm').format(DateTime(record.date.year, record.date.month, record.date.day, record.date.hour, record.date.minute)), style: TextStyle(fontSize: 12), textAlign: TextAlign.end,)),
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
                    key: ValueKey<BladderBowel>(widget.bladderBowelRecords[i]),
                    onDismissed: (left) {
                      setState(() {
                        widget.bladderBowelRecords.removeAt(i);
                        widget.onBladderBowelRecordUpdated(widget.bladderBowelRecords);
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
            widget.bladderBowelRecords.add(newRecord);
            widget.onBladderBowelRecordUpdated(widget.bladderBowelRecords);
          });
        });
      },
    );
  }

  _BladderBowelPageState();
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
  int bowel = -1;
  int bladder = -1;
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
                      Expanded(child: Text("ถ่ายและฉี่", style: TextStyle(fontSize: 12.0),)),
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
              Text("ถ่ายและฉี่", style: TextStyle(fontWeight: FontWeight.bold,),),
              SizedBox(height: 4.0,),
              Row(
                children: [
                  Container(
                    width: 64,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'ถ่าย',
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
                        bowel = int.parse(input);
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
                      Text('ถ่าย', style: TextStyle(fontWeight: FontWeight.w100, fontSize: 12)),
                    ],
                  ),
                  SizedBox(width: 4,),
                  Container(
                    width: 64,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'ฉี่',
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
                        bladder = int.parse(input);
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
                      Text('ฉี่', style: TextStyle(fontWeight: FontWeight.w100, fontSize: 12)),
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
            else if (bowel >= 0 && bladder >= 0) {
              widget.onRecordAdded(BladderBowel(date: dateTime, bowel: bowel, bladder: bladder));
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


class BladderBowel {
  BladderBowel(
      {required this.date, required this.bowel, required this.bladder});

  final DateTime date;
  final int bowel;
  final int bladder;

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['date'] = date.millisecondsSinceEpoch;
    data['bowel'] = bowel;
    data['bladder'] = bladder;
    return data;
  }

  static BladderBowel fromJson(Map<String, dynamic> json) {
    int date = json['date'];
    int bowel = json['bowel'];
    int bladder = json['bladder'];
    print("json = $json");
    final record = BladderBowel(
        date: DateTime.fromMillisecondsSinceEpoch(date),
        bowel: bowel,
        bladder: bladder,
    );
    return record;
  }

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}