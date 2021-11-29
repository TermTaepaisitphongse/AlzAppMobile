import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';

import 'BloodPressurePage.dart';
import 'PatientRecordPage.dart';

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
    /* for (int i=0;i<2;i++){
      patients.add(Patient(name:'John $i'));
    } */
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
    final colors = Colors.accents;
    final _random = new Random();
    var randomColor = colors[_random.nextInt(colors.length)];

    return GestureDetector(
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
      onPanUpdate: (details){
        if (details.delta.dx < -2) {
          print('pan');
        }
      },
      child: ListTile(
        title: Material(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: randomColor,
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
      ),
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
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Add a new patient"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,

                children: <Widget>[
                  TextFormField(
                    decoration: new InputDecoration(labelText: "Patient's Name:"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      else{
                        currentName = value;
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: new InputDecoration(labelText: "Caretaker's Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
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
            ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Added Successfully!')));
                  setState(() {
                    patients.add(Patient(name:currentName, caretakerName: currentCaretakerName));
                    _updatePatientToLocal();
                    _resetFiltered();
                  });
                  Navigator.pop(context);
                }
              }, child: Text("Add"),
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
  Patient({required this.name, required this.caretakerName});
  String name;
  String caretakerName;
  List<Record> records = [];
  List<BloodPressure> bloodPressures = [];

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['name'] = name;
    data['caretakerName'] = caretakerName;
    final dataRecord = records.map((e) => e.toJson()).toList();
    final bloodPressureRecord = bloodPressures.map((e) => e.toJson()).toList();
    data['records'] = dataRecord;
    data['bloodPressures'] = bloodPressureRecord;
    return data;
  }

  static Patient fromJson(Map<String, dynamic> json) {
    final jsonRecords = json['bloodPressures'] as List<dynamic>;
    final bloodPressureRecord = jsonRecords.map((e) => BloodPressure.fromJson(e)).toList();
    print("bprecord = $bloodPressureRecord");
    final patient = Patient(name: json['name'], caretakerName: json['caretakerName']);
    patient.bloodPressures = bloodPressureRecord;
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