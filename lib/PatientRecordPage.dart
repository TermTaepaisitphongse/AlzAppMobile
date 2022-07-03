import 'package:alzapp/RespiratoryRatePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'BloodPressurePage.dart';
import 'PulsePage.dart';
import 'RespiratoryRatePage.dart';
import 'TemperaturePage.dart';
import 'DextrostixPage.dart';
import 'WeightPage.dart';
import 'main.dart';

void main() => runApp(MyApp());

// #docregion MyApp
class MyApp extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    Patient patient = Patient(name: 'name', caretakerName: 'caretakerName', RGBcolor: [Colors.white.red, Colors.white.green, Colors.white.blue]);
    return MaterialApp(
      title: 'AlzApp Health Records',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: PatientRecordPage(patient, (p) {}),
    );
  }
// #enddocregion build
}

class PatientRecordPage extends StatefulWidget {
  PatientRecordPage(this.patient, this.onPatientChange);

  final Patient patient;
  Function onPatientChange;

  @override
  _PatientRecordPageState createState() => _PatientRecordPageState();
}

class _PatientRecordPageState extends State<PatientRecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        centerTitle: true,
        title: Text(widget.patient.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'บันทึกสุขภาพ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BloodPressurePage(
                              fullName: widget.patient.name,
                              bloodPressureRecords: widget.patient.bloodPressures,
                              onBPRecordUpdated: (newRecords){widget.patient.bloodPressures = newRecords;
                              widget.onPatientChange(widget.patient);
                              },
                            )),
                      );
                    },
                    child: Material(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SvgPicture.asset('assets/bloodPressure.svg',
                                height: 38.0),
                            SizedBox(
                              height: 16.0,
                            ),
                            Text(
                              'ความดันเลือด',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 24.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PulsePage(
                              fullName: widget.patient.name,
                              pulseRecords: widget.patient.pulse,
                              onPulseRecordUpdated: (newRecords){widget.patient.pulse = newRecords;
                              print(newRecords);
                              print(widget.patient.toJson().toString());
                              widget.onPatientChange(widget.patient);
                              },
                            )),
                      );
                    },
                    child: Material(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SvgPicture.asset('assets/pulse.svg', height: 38.0),
                            SizedBox(
                              height: 16.0,
                            ),
                            Text(
                              'ชีพจร',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      color: Colors.purpleAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RespiratoryRatePage(
                              fullName: widget.patient.name,
                              respiratoryRecords: widget.patient.respiratoryRate,
                              onRespiratoryRecordUpdated: (newRecords){widget.patient.respiratoryRate = newRecords;
                              print(newRecords);
                              print(widget.patient.toJson().toString());
                              widget.onPatientChange(widget.patient);
                              },
                            )),
                      );
                    },
                    child: Material(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SvgPicture.asset('assets/respiratoryRate.svg', height: 38.0, color: Colors.white),
                            SizedBox(
                              height: 16.0,
                            ),
                            Text(
                              'อัตราการหายใจ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 24.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TemperaturePage(
                              fullName: widget.patient.name,
                              temperatureRecords: widget.patient.temperature,
                              onTemperatureRecordUpdated: (newRecords){widget.patient.temperature = newRecords;
                              print(newRecords);
                              print(widget.patient.toJson().toString());
                              widget.onPatientChange(widget.patient);
                              },
                            )),
                      );
                    },
                    child: Material(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SvgPicture.asset('assets/temperature.svg', height: 38.0),
                            SizedBox(
                              height: 16.0,
                            ),
                            Text(
                              'อุณหภูมิร่างกาย',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DextrostixPage(
                              fullName: widget.patient.name,
                              dextrostixRecords: widget.patient.dextrostix,
                              onDextrostixRecordUpdated: (newRecords){widget.patient.dextrostix = newRecords;
                              print(newRecords);
                              print(widget.patient.toJson().toString());
                              widget.onPatientChange(widget.patient);
                              },
                            )),
                      );
                    },
                    child: Material(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SvgPicture.asset('assets/dextrostix.svg', height: 38.0, color: Colors.white),
                            SizedBox(
                              height: 16.0,
                            ),
                            Text(
                              'น้ำตาลในเลือด',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 24.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WeightPage(
                              fullName: widget.patient.name,
                              weightRecords: widget.patient.weight,
                              onWeightRecordUpdated: (newRecords){widget.patient.weight = newRecords;
                              print(newRecords);
                              print(widget.patient.toJson().toString());
                              widget.onPatientChange(widget.patient);
                              },
                            )),
                      );
                    },
                    child: Visibility(
                      visible: true,
                      child: Material(
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              SvgPicture.asset('assets/weight.svg', height: 38.0, color: Colors.white),
                              SizedBox(
                                height: 16.0,
                              ),
                              Text(
                                'น้ำหนัก',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
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

// #enddocregion RWS-var

class Record {
  Record(
      {required this.dateTime,
      this.temperature,
      this.bloodPressure,
      this.pulse,
      this.rr,
      this.dtx,
      this.notes});

  DateTime dateTime;
  double? temperature;
  double? bloodPressure;
  double? pulse;
  double? rr;
  double? dtx;
  String? notes;

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['dateTime'] = dateTime.millisecondsSinceEpoch;
    data['temperature'] = temperature;
    data['bloodPressure'] = bloodPressure;
    data['pulse'] = pulse;
    data['rr'] = rr;
    data['dtx'] = dtx;
    data['notes'] = notes;
    return data;
  }

  static Record fromJson(Map<String, dynamic> json) {
    int dateTime = json['dateTime'];
    double temperature = json['temperature'];
    double bloodPressure = json['bloodPressure'];
    double pulse = json['pulse'];
    double rr = json['rr'];
    double dtx = json['dtx'];
    String notes = json['notes'];
    final record = Record(
        dateTime: DateTime.fromMillisecondsSinceEpoch(dateTime),
        temperature: temperature,
        bloodPressure: bloodPressure,
        pulse: pulse,
        rr: rr,
        dtx: dtx,
        notes: notes);
    return record;
  }
}

// Create a Form widget.
class RecordForm extends StatefulWidget {
  @override
  AddRecordForm createState() {
    return AddRecordForm();
  }
}

class AddRecordForm extends State<RecordForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                  //patients.add(Patient(name:value));
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
