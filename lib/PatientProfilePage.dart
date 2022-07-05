import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Profile Page',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 24.0),
                Text("Patient Name: " + widget.patient.name),
                Text("Caretaker Name: " + widget.patient.caretakerName),
                Text("Gender: " + widget.patient.gender.name),
                Text("DoB: " + widget.patient.dateOfBirth.year.toString()),
                Text("Notes: " + widget.patient.notes),
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

// #enddocregion RWS-var
