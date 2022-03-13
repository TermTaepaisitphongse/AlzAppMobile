import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

import 'PatientRecordPage.dart';
import 'BloodPressurePage.dart';
import 'package:alzapp/PulsePage.dart';
import 'package:alzapp/RespiratoryRatePage.dart';
import 'package:alzapp/TemperaturePage.dart';
import 'package:alzapp/DextrostixPage.dart';
import 'package:alzapp/BladderBowelPage.dart';


void main() => runApp(MyApp());

// #docregion MyApp
class MyApp extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlzApp Health Records',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: PatientItem(),
    );
  }
// #enddocregion build
}
// #enddocregion MyApp

// #docregion RWS-var
class _PatientItemState extends State<PatientItem> {
  final List<Patient> patients  = [];
  List<Patient> filteredPatients = [];
  late SearchBar searchBar;
  // #enddocregion RWS-var

  // #docregion _buildSuggestions
  Widget _buildPatientList() {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: filteredPatients.length,
        itemBuilder: (context, i) {
          return _buildRow(filteredPatients[i]);
        });
  }
  // #enddocregion _buildSuggestions

  // #docregion _buildRow
  Widget _buildRow(Patient p) {
    return ListTile(
      title: Material(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color.fromARGB(255, p.RGBcolor[0], p.RGBcolor[1], p.RGBcolor[2]),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0,horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${p.name}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      "${p.caretakerName}",
                      style: TextStyle(fontSize: 14, color: Colors.black38),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: (){
                    setState(() {
                      patients.remove(p);
                      _updatePatientToLocal();
                      _resetFiltered();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PatientRecordPage(p, (Patient patient){
            print(patient.bloodPressures);
            final index = patients.indexOf(p);
            patients[index] = patient;
            _updatePatientToLocal();
          })),
        );
      },
    );
  }
  // #enddocregion _buildRow
  void initList() async{
    final sharedPrefs = await SharedPreferences.getInstance();
    final value = sharedPrefs.getString('patients')??'[]';
    print("storedvalue = $value");
    final map = json.decode(value) as List<dynamic>;
    final patientList = map.map((patient) {
      return Patient.fromJson(patient);
    }).toList();
    setState(() {
      patients.clear();
      patients.addAll(patientList);
      _resetFiltered();
    });
  }

  @override
  void initState() {
    initList();

    //search bar init
    searchBar = SearchBar(
        inBar: false,
        setState: setState,
        onSubmitted: (text){
          _resetFiltered();
        },
        onClosed: (){
          _resetFiltered();
        },
        buildDefaultAppBar: _buildAppBar
    );
    searchBar.controller.addListener(() {
      _filterWith(searchBar.controller.text);
    });

    super.initState();
  }

  void _resetFiltered(){
    filteredPatients.clear();
    filteredPatients.addAll(patients);
  }
  void _filterWith(String text){
    filteredPatients.clear();
    final filtered = patients.where((element) {
      final shouldRetain = text == "" || element.name.toLowerCase()
          .contains(text.toLowerCase()) ||
          element.caretakerName.toLowerCase().contains(text.toLowerCase());
      return shouldRetain;
    }).toList();

    setState(() {
      filteredPatients.addAll(filtered);
    });
  }
  AppBar _buildAppBar(BuildContext context){
    return AppBar(
      title: Text("AlzApp"),
      actions: [
        searchBar.getSearchAction(context)
      ],
    );
  }

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchBar.build(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Patients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
          ),
          Expanded(child: _buildPatientList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: () => _showDialog(context)),
      );
    }

  void _showDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String currentName = "";
    String currentCaretakerName = "";
    final colors = Colors.accents;
    final _random = new Random();
    Color currentColor = colors[_random.nextInt(colors.length)];
    String errorMessage = "";
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        print(errorMessage);
        return AlertDialog(
          title: new Text("เพิ่มรายชื่อใหม่"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,

                children: <Widget>[
                  TextFormField(
                    decoration: new InputDecoration(labelText: "ชื่อ Patient's:"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกข้อความนี่';
                      }
                      else{
                        currentName = value;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: new InputDecoration(labelText: "ชื่อ Caretaker's"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกข้อความนี่';
                      }
                      else{
                        currentCaretakerName = value;
                      }
                      return null;
                    },
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
            Row(
              children: [
                Expanded(child: Text(errorMessage, textAlign: TextAlign.end,)),
                SizedBox(width: 4,),
                ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      final patientWithSameName = patients.firstWhereOrNull((element) => element.name == currentName);
                      print(patientWithSameName);
                      if (patientWithSameName!=null){
                        setState(() {
                          errorMessage = "มีผู้ป่วยชื่อนี้แล้ว กรุณาใช้ชื่ออื่น";
                        });
                      }
                      else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('เพิ่มเรียบร้อย!')));
                        setState(() {
                          patients.add(Patient(name: currentName, caretakerName: currentCaretakerName, RGBcolor: [currentColor.red, currentColor.green, currentColor.blue]));
                          _updatePatientToLocal();
                          _resetFiltered();
                        });
                        Navigator.pop(context);
                      }
                    }
                  }, child: Text("Add"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  void _updatePatientToLocal() async{
    final sharedPrefs = await SharedPreferences.getInstance();
    final jsonList = patients.map((p) => p.toJson()).toList();
    sharedPrefs.setString('patients', json.encode(jsonList));
    print('jsonList = $jsonList');
    final value = sharedPrefs.getString('patients');
    print('preferenceValue = $value');
  }
}


// #enddocregion RWS-var

class PatientItem extends StatefulWidget {
  @override
  State<PatientItem> createState() => _PatientItemState();
}

class Patient {
  Patient({required this.name, required this.caretakerName, required this.RGBcolor});
  String name;
  String caretakerName;
  List<int> RGBcolor;
  List<Record> records = [];
  List<BloodPressure> bloodPressures = [];
  List<Pulse> pulse = [];
  List<RespiratoryRate> respiratoryRate = [];
  List<Temperature> temperature = [];
  List<Dextrostix> dextrostix = [];
  List<BladderBowel> bladderBowel = [];

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['name'] = name;
    data['caretakerName'] = caretakerName;
    data['color'] = RGBcolor;
    final dataRecord = records.map((e) => e.toJson()).toList();
    final bloodPressureRecord = bloodPressures.map((e) => e.toJson()).toList();
    final pulseRecord = pulse.map((e) => e.toJson()).toList();
    final respiratoryRateRecord = respiratoryRate.map((e) => e.toJson()).toList();
    final temperatureRecord = temperature.map((e) => e.toJson()).toList();
    final dextrostixRecord = dextrostix.map((e) => e.toJson()).toList();
    final bladderBowelRecord = bladderBowel.map((e) => e.toJson()).toList();
    data['records'] = dataRecord;
    data['bloodPressures'] = bloodPressureRecord;
    data['pulse'] = pulseRecord;
    data['respiratoryRate'] = respiratoryRateRecord;
    data['temperature'] = temperatureRecord;
    data['dextrostix'] = dextrostixRecord;
    data['bladderBowel'] = bladderBowelRecord;
    return data;
  }

  static Patient fromJson(Map<String, dynamic> json) {
    final jsonRGBcolor = json['color'] as List<dynamic>;
    final color = jsonRGBcolor.map((e) => e as int).toList();
    final jsonBP = json['bloodPressures'] as List<dynamic>;
    final jsonPulse = json['pulse'] as List<dynamic>;
    final jsonRespiratoryRate = json['respiratoryRate'] as List<dynamic>;
    final jsonTemperature = json['temperature'] as List<dynamic>;
    final jsonDextrostix = json['dextrostix'] as List<dynamic>;
    final jsonBladderBowel = json['bladderBowel'] as List<dynamic>;
    final bloodPressureRecord = jsonBP.map((e) => BloodPressure.fromJson(e)).toList();
    final pulseRecord = jsonPulse.map((e) => Pulse.fromJson(e)).toList();
    final respiratoryRateRecord = jsonRespiratoryRate.map((e) => RespiratoryRate.fromJson(e)).toList();
    final temperatureRecord = jsonTemperature.map((e) => Temperature.fromJson(e)).toList();
    final dextrostixRecord = jsonDextrostix.map((e) => Dextrostix.fromJson(e)).toList();
    final bladderBowelRecord = jsonBladderBowel.map((e) => BladderBowel.fromJson(e)).toList();
    print("bprecord = $bloodPressureRecord");
    final patient = Patient(name: json['name'], caretakerName: json['caretakerName'], RGBcolor: color);
    patient.bloodPressures = bloodPressureRecord;
    patient.pulse = pulseRecord;
    patient.respiratoryRate = respiratoryRateRecord;
    patient.temperature = temperatureRecord;
    patient.dextrostix = dextrostixRecord;
    patient.bladderBowel = bladderBowelRecord;
    return patient;
  }
}

// Create a Form widget.
class PatientForm extends StatefulWidget {
  @override
  AddPatientForm createState() {
    return AddPatientForm();
  }
}

class AddPatientForm extends State<PatientForm> {
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