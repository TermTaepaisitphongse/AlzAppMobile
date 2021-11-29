import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'BloodPressurePage.dart';
import 'main.dart';

void main() => runApp(MyApp());

// #docregion MyApp
class MyApp extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    Patient patient = Patient(name: 'name', caretakerName: 'caretakerName');
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
              'Records',
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
                              bloodPressureRecords: widget.patient.bloodPressures,
                              onBPRecordUpdated: (newRecords){widget.patient.bloodPressures = newRecords;
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
                            SvgPicture.asset('assets/bloodPressure.svg',
                                height: 38.0),
                            SizedBox(
                              height: 16.0,
                            ),
                            Text(
                              'Blood Pressure',
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
                            'Pulse',
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Material(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/respiratoryRate.svg',
                              height: 38.0, color: Colors.white),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text(
                            'Respiratory Rate',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 24.0),
                Expanded(
                  child: Material(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/temperature.svg',
                              height: 38.0),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text(
                            'Temperature',
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Material(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/dextrostix.svg',
                              height: 38.0, color: Colors.white),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text(
                            'Dextrostix',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 24.0),
                Expanded(
                  child: Material(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/bladderBowel.svg',
                              height: 38.0, color: Colors.white),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text(
                            'Bladder & Bowel',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(8),
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

  void _showDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final padding = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
    );
    double? currentTemperature;
    double? currentBloodPressure;
    double? currentPulse;
    double? currentRR;
    double? currentDTX;
    String? currentNotes;
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Add a new record"),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration:
                      new InputDecoration(labelText: "Temperature (°C):"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    } else {
                      try {
                        currentTemperature = double.parse(value);
                      } catch (Exception) {
                        return "Please enter a valid number";
                      }
                    }
                    return null;
                  },
                ),
                padding,
                TextFormField(
                  decoration:
                      new InputDecoration(labelText: "Blood Pressure (mmHg):"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    } else {
                      try {
                        currentBloodPressure = double.parse(value);
                      } catch (Exception) {
                        return "Please enter a valid number";
                      }
                    }
                    return null;
                  },
                ),
                padding,
                TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Pulse (beats per minute):"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    } else {
                      try {
                        currentPulse = double.parse(value);
                      } catch (Exception) {
                        return "Please enter a valid number";
                      }
                    }
                    return null;
                  },
                ),
                padding,
                TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Respiratory Rate (breaths per minute):"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    } else {
                      try {
                        currentRR = double.parse(value);
                      } catch (Exception) {
                        return "Please enter a valid number";
                      }
                    }
                    return null;
                  },
                ),
                padding,
                TextFormField(
                  decoration:
                      new InputDecoration(labelText: "Dextrostix (mg%):"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    } else {
                      try {
                        currentDTX = double.parse(value);
                      } catch (Exception) {
                        return "Please enter a valid number";
                      }
                    }
                    return null;
                  },
                ),
                padding,
                TextFormField(
                  decoration: new InputDecoration(labelText: "Notes/Symptoms:"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    } else {
                      currentNotes = value;
                    }
                    return null;
                  },
                ),
                padding,
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added Successfully!')));
                  setState(() {
                    final temperature = currentTemperature;
                    final bloodPressure = currentBloodPressure;
                    final pulse = currentPulse;
                    final rr = currentRR;
                    final dtx = currentDTX;
                    final notes = currentNotes;
                    widget.patient.records.add(Record(
                        dateTime: DateTime.now(),
                        temperature: temperature,
                        bloodPressure: bloodPressure,
                        pulse: pulse,
                        rr: rr,
                        dtx: dtx,
                        notes: notes));
                    widget.onPatientChange(widget.patient);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
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
