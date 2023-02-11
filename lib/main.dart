import 'dart:convert';
import 'dart:math';
import 'package:alzapp/SettingsPage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import 'PatientRecordPage.dart';
import 'BloodPressurePage.dart';
import 'package:alzapp/PulsePage.dart';
import 'package:alzapp/RespiratoryRatePage.dart';
import 'package:alzapp/TemperaturePage.dart';
import 'package:alzapp/DextrostixPage.dart';
import 'package:alzapp/WeightPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final stringlocale = await getLocale();
  print(stringlocale);
  runApp(MyApp(stringLocale : 'TH'));
}

// #docregion MyApp
class MyApp extends StatelessWidget {
  final String stringLocale;

  const MyApp({Key? key, required this.stringLocale}) : super(key: key);
  // #docregion build
  @override
  Widget build(BuildContext context) {
    print('myapp');
    Locale locale;
    if (stringLocale == "US") {
      locale = Locale('en', 'US');
    }
    else {
      locale = Locale('th', 'TH');
    }
    print(locale);
    print(context);
    print(context.supportedLocales);

    return MaterialApp(
      title: 'AlzApp Health Records',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: PatientItem(),
      // home: EasyLocalization(
      //     path: 'locales',
      //     supportedLocales: [Locale('en', 'US'), Locale('th', 'TH')],
      //     child: PatientItem()),
      // localizationsDelegates: context.localizationDelegates,
      // supportedLocales: context.supportedLocales,
      // locale: locale,
    );
  }
// #enddocregion build
}
// #enddocregion MyApp

// #docregion RWS-var
class _PatientItemState extends State<PatientItem> {
  final List<Patient> patients = [];
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
    print('buildrow');
    return ListTile(
      title: Material(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Color.fromARGB(255, p.RGBcolor[0], p.RGBcolor[1], p.RGBcolor[2]),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
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
                    Text("${p.name}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
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
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('confirm_delete_patient'.tr()),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('do_not_delete'.tr())),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        patients.remove(p);
                                        _updatePatientToLocal();
                                        _resetFiltered();
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text('delete'.tr()))
                              ],
                            ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PatientRecordPage(p, (Patient patient) {
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
  void initList() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final value = sharedPrefs.getString('patients') ?? '[]';
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
    initPackageInfo();

    //search bar init
    searchBar = SearchBar(
        inBar: false,
        setState: setState,
        onSubmitted: (text) {
          _resetFiltered();
        },
        onClosed: () {
          _resetFiltered();
        },
        buildDefaultAppBar: _buildAppBar);
    searchBar.controller.addListener(() {
      _filterWith(searchBar.controller.text);
    });

    super.initState();
  }

  String version = "";

  void initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  void _resetFiltered() {
    filteredPatients.clear();
    filteredPatients.addAll(patients);
  }

  void _filterWith(String text) {
    filteredPatients.clear();
    final filtered = patients.where((element) {
      final shouldRetain = text == "" ||
          element.name.toLowerCase().contains(text.toLowerCase()) ||
          element.caretakerName.toLowerCase().contains(text.toLowerCase());
      return shouldRetain;
    }).toList();

    setState(() {
      filteredPatients.addAll(filtered);
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Text('app_name'.tr(), style: TextStyle(fontSize: 25)),
          SizedBox(
            width: 5,
          ),
          Text(
            version,
            style: TextStyle(fontSize: 10),
          ),
        ],
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
      ),
      actions: [searchBar.getSearchAction(context)],
    );
  }

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {
    final emptyWidget = Center(
        child: Column(
      children: [
        Text('add_new_patient'.tr(),
            style: TextStyle(color: CupertinoColors.systemGrey2)),
        SizedBox(height: 6),
        Icon(Icons.add, color: CupertinoColors.systemGrey2),
      ],
      mainAxisSize: MainAxisSize.min,
    ));

    return Scaffold(
      appBar: searchBar.build(context),
      drawer: Drawer(child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 64,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('app_name'.tr()),
            ),
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 8,),
                const Text('About the App'),
              ],
            ),
            onTap: () {
              print('tap');
              showAboutDialog(
                  context: context,
                  applicationName: 'infodialog_title'.tr(),
                  applicationIcon: SizedBox(
                    child: Image.asset('assets/AlzAppIcon.png'),
                    width: 32,
                    height: 32,
                  ),
                  applicationVersion: "",
                  children: [
                    Text(
                        'infodialog_desc'.tr()),
                    SizedBox(
                      height: 16,
                    ),
                    Text('infodialog_term_fullname_prefix'.tr()),
                    Text('infodialog_term_fullname'.tr()),
                    Row(
                      children: [
                        Text('infodialog_email_prefix'.tr()),
                        GestureDetector(
                          child: Text('infodialog_email'.tr(),
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue)),
                          onTap: () async {
                            final Uri url =
                            Uri.parse('mailto:termpt2222@gmail.com');
                            if (await canLaunchUrl(url)) launchUrl(url);
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('infodialog_thank_you'.tr())
                  ]);
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.settings),
                SizedBox(width: 8,),
                const Text('Settings'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      )),
      body: Container(
          child: patients.isEmpty
              ? GestureDetector(
                  child: emptyWidget, onTap: () => _showDialog(context))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'patient'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    Expanded(child: _buildPatientList()),
                  ],
                )),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add), onPressed: () => _showDialog(context)),
    );
  }

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return PatientForm(patients, (newPatient) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('added_successfully'.tr())));
          setState(() {
            patients.add(newPatient);
            _updatePatientToLocal();
            _resetFiltered();
          });
        });
      },
    );
  }

  void _updatePatientToLocal() async {
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
  Patient(
      {required this.name,
      required this.caretakerName, required this.gender,required this.dateOfBirth, required this.height, required this.notes,
      required this.RGBcolor,});

  String name;
  String caretakerName;
  Gender gender;
  DateTime dateOfBirth;
  int? height;
  String? notes;
  String? imagePath;
  List<int> RGBcolor;
  List<Record> records = [];
  List<BloodPressure> bloodPressures = [];
  List<Pulse> pulse = [];
  List<RespiratoryRate> respiratoryRate = [];
  List<Temperature> temperature = [];
  List<Dextrostix> dextrostix = [];
  List<Weight> weight = [];

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['name'] = name;
    data['caretakerName'] = caretakerName;
    data['gender'] = gender.toString();
    data['dateOfBirth'] = dateOfBirth.millisecondsSinceEpoch;
    data['height'] = height;
    data['notes'] = notes;
    data['imagePath'] = imagePath;
    data['color'] = RGBcolor;
    final dataRecord = records.map((e) => e.toJson()).toList();
    final bloodPressureRecord = bloodPressures.map((e) => e.toJson()).toList();
    final pulseRecord = pulse.map((e) => e.toJson()).toList();
    final respiratoryRateRecord =
        respiratoryRate.map((e) => e.toJson()).toList();
    final temperatureRecord = temperature.map((e) => e.toJson()).toList();
    final dextrostixRecord = dextrostix.map((e) => e.toJson()).toList();
    final weightRecord = weight.map((e) => e.toJson()).toList();
    data['records'] = dataRecord;
    data['bloodPressures'] = bloodPressureRecord;
    data['pulse'] = pulseRecord;
    data['respiratoryRate'] = respiratoryRateRecord;
    data['temperature'] = temperatureRecord;
    data['dextrostix'] = dextrostixRecord;
    data['weight'] = weightRecord;
    return data;
  }

  static Patient fromJson(Map<String, dynamic> json) {
    final jsonGender = json['gender'] as String?;
    final jsonDateOfBirth = json['dateOfBirth'] as int?;
    final jsonHeight = json['height'] as int?;
    final jsonNotes = json['notes'] as String?;
    final jsonImagePath = json['imagePath'] as String?;
    final jsonRGBcolor = json['color'] as List<dynamic>;

    final jsonBP = json['bloodPressures'] as List<dynamic>?;
    final jsonPulse = json['pulse'] as List<dynamic>?;
    final jsonRespiratoryRate = json['respiratoryRate'] as List<dynamic>?;
    final jsonTemperature = json['temperature'] as List<dynamic>?;
    final jsonDextrostix = json['dextrostix'] as List<dynamic>?;
    final jsonWeight = json['weight'] as List<dynamic>?;
    final gender = createGenderFromString(jsonGender);
    final dateOfBirth = DateTime.fromMillisecondsSinceEpoch(jsonDateOfBirth ?? 0);
    final notes = jsonNotes;
    final imagePath = jsonImagePath;
    final color = jsonRGBcolor.map((e) => e as int).toList();
    final weightRecord =
        jsonWeight?.map((e) => Weight.fromJson(e)).toList();
    final bloodPressureRecord = jsonBP?.map((e) => BloodPressure.fromJson(e)).toList();
    final pulseRecord = jsonPulse?.map((e) => Pulse.fromJson(e)).toList();
    final respiratoryRateRecord = jsonRespiratoryRate?.map((e) => RespiratoryRate.fromJson(e)).toList();
    final temperatureRecord = jsonTemperature?.map((e) => Temperature.fromJson(e)).toList();
    final dextrostixRecord = jsonDextrostix?.map((e) => Dextrostix.fromJson(e)).toList();
    print("bprecord = $bloodPressureRecord");
    final patient = Patient(
        name: json['name'],
        caretakerName: json['caretakerName'],
        gender: gender,
        dateOfBirth: dateOfBirth,
        height: jsonHeight,
        notes: notes,
        RGBcolor: color);
    patient.imagePath = imagePath;
    patient.bloodPressures = bloodPressureRecord ?? [];
    patient.pulse = pulseRecord ?? [];
    patient.respiratoryRate = respiratoryRateRecord ?? [];
    patient.temperature = temperatureRecord ?? [];
    patient.dextrostix = dextrostixRecord ?? [];
    patient.weight = weightRecord ?? [];
      return patient;
  }
}

enum Gender {
  Male,
  Female,
  Other
}

createGenderFromString(String? gender){
  if (gender?.contains("Male") ?? false) {
    return Gender.Male;
  }
  else if (gender?.contains("Female") ?? false) {
    return Gender.Female;
  }
  else {
    return Gender.Other;
  }
}

extension createStringFromGender on Gender {
  String get returnString {
    if (name == "Male") {
      return 'male'.tr();
    }
    else if (name == "Female") {
      return 'female'.tr();
    }
    else {
      return 'other'.tr();
    }
  }
}

// Create a Form widget.
class PatientForm extends StatefulWidget {
  final List<Patient> patients;

  PatientForm(this.patients, this.onAdded);

  final Function onAdded;

  @override
  AddPatientForm createState() {
    return AddPatientForm();
  }
}

class AddPatientForm extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();
  String currentName = "";
  String currentCaretakerName = "";
  Gender currentGender = Gender.Male;
  DateTime currentDateOfBirth = DateTime.now();
  int currentHeight = 0;
  String currentNotes = "";
  final colors = Colors.accents;
  final _random = new Random();
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    Color currentColor = colors[_random.nextInt(colors.length)];
    // Build a Form widget using the _formKey created above.
    return AlertDialog(
      title: new Text('newpatient_title'.tr()),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: new InputDecoration(labelText: 'newpatient_name'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'required'.tr();
                  } else {
                    currentName = value;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16,),
              Row(
                children: [
                  Text('gender'.tr() + ":", style: TextStyle(color: Colors.grey),),
                  SizedBox(width: 16,),
                  DropdownButton<Gender>(
                    value: currentGender,
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                    onChanged: (Gender? changeGender) {
                      setState(() {
                        currentGender = changeGender!;
                      });
                    },
                    items: Gender.values.map<DropdownMenuItem<Gender>>((Gender value) {
                      return DropdownMenuItem<Gender>(
                        value: value,
                        child: Text(value.returnString),
                      );
                    }).toList(),
                  ),
                ],
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: 'birth_year'.tr()),
                  keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'required'.tr();
                  }
                  else if (int.parse(value) < (DateTime.now().year + 543) - 100 || int.parse(value) > DateTime.now().year + 543) {
                    return 'incorrect_input'.tr();
                  }
                  else {
                    currentDateOfBirth = DateTime(int.parse(value));
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: 'height'.tr()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'required'.tr();
                  }
                  else if (int.parse(value) <= 0) {
                    return 'incorrect_height'.tr();
                  }
                  else {
                    currentHeight = int.parse(value);
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: 'notes'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    currentNotes = "";
                  } else {
                    currentNotes = value;
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: new InputDecoration(labelText: 'caretaker_name'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'required'.tr();
                  } else {
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
            Expanded(
                child: Text(
              errorMessage,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.red),
            )),
            SizedBox(
              width: 4,
            ),
            ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  final patientWithSameName = widget.patients.firstWhereOrNull(
                      (element) => element.name == currentName);
                  print(patientWithSameName);
                  if (patientWithSameName != null) {
                    setState(() {
                      errorMessage = 'repeated_patient_name_error'.tr();
                    });
                  } else {
                    widget.onAdded(Patient(
                        name: currentName,
                        caretakerName: currentCaretakerName,
                        gender: currentGender,
                        dateOfBirth: currentDateOfBirth,
                        height: currentHeight,
                        notes: currentNotes,
                        RGBcolor: [
                          currentColor.red,
                          currentColor.green,
                          currentColor.blue
                        ]));
                    Navigator.pop(context);
                  }
                }
              },
              child: Text('add'.tr()),
            ),
          ],
        ),
      ],
    );
  }
}
