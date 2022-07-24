import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      home: PatientProfilePage(patient, (p) {}),
    );
  }
// #enddocregion build
}

class PatientProfilePage extends StatefulWidget {
  PatientProfilePage(this.patient, this.onPatientChange);

  final Patient patient;
  Function onPatientChange;

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  ImageProvider? currentImage;

  @override
  void initState() {
    final imagePath = widget.patient.imagePath;
    if (imagePath != null) {
      if (kIsWeb) {
        currentImage = NetworkImage(imagePath);
      } else {
        currentImage = FileImage(File(imagePath));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? chosenImage;
    print(currentImage);
    if (currentImage != null){
      chosenImage = currentImage;
    }
    else {
      chosenImage = AssetImage("assets/AlzAppIcon.png");
    }

      return Scaffold(
        appBar: AppBar(
            leading: BackButton(),
            centerTitle: true,
            title: Text(widget.patient.name)
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                child: CircleAvatar(
                  backgroundImage: chosenImage,
                  radius: 64,
                ),
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  // Pick an image
                  final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    if (selectedImage != null) {
                      if (kIsWeb) {
                        currentImage = NetworkImage(selectedImage.path);
                      } else {
                        currentImage = FileImage(File(selectedImage.path));
                      }
                      widget.patient.imagePath = selectedImage.path;
                      widget.onPatientChange(widget.patient);
                    }
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 16,
                child: Padding(
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
