import 'package:flutter/material.dart';

import 'main.dart';

void main() => runApp(MyApp());

// #docregion MyApp
class MyApp extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    Patient patient = Patient(name: 'name', caretakerName: 'caretakerName', gender: Gender.Male, dateOfBirth: DateTime.now(), notes: "hello", RGBcolor: [Colors.white.red, Colors.white.green, Colors.white.blue]);
    return MaterialApp(
      title: 'AlzApp Health Records',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: PatientProfilePage(patient),
    );
  }
// #enddocregion build
}

class PatientProfilePage extends StatefulWidget {
  PatientProfilePage(this.patient);

  final Patient patient;

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  @override
  Widget build(BuildContext context) {
    print(widget.patient.gender.name);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        centerTitle: true,
        title: Text(widget.patient.name)
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text('iamge'),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 24.0),
                Row(
                  children: [
                    Icon(chosenIcon(widget.patient), size: 32, color: Colors.blueAccent),
                    SizedBox(width: 16,),
                    Text("เพศ: " + widget.patient.gender.returnString, style: TextStyle(fontSize: 32, color: Colors.black45),),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.cake, size: 32, color: Colors.blueAccent,),
                    SizedBox(width: 16,),
                    Text("ปีเกิด: " + widget.patient.dateOfBirth.year.toString(), style: TextStyle(fontSize: 32, color: Colors.black45,)),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.assignment_ind, size: 32, color: Colors.blueAccent,),
                    SizedBox(width: 16,),
                    Text("ชื่อผู้ดูแล: " + widget.patient.caretakerName, style: TextStyle(fontSize: 32, color: Colors.black45),),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.notes, size: 32, color: Colors.blueAccent,),
                    SizedBox(width: 16,),
                    Text("ข้อมูลเพิ่มเติม: " + (widget.patient.notes ?? ''), style: TextStyle(fontSize: 32, color: Colors.black45),),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //     child: Icon(Icons.add), onPressed: () => _showDialog(context)),
    );
  }
}

chosenIcon(Patient patient){
  switch(patient.gender.name) {
    case "Male": {  return Icons.male; }
    case "Female": {  return Icons.female; }
    case "Other": {  return Icons.person; }
  }
}

// #enddocregion RWS-var
