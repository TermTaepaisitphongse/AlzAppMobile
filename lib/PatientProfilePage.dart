import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

import 'main.dart';

class PatientProfilePage extends StatefulWidget {
  PatientProfilePage(this.patient, this.onPatientChange);

  final Patient patient;
  Function onPatientChange;

  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  ImageProvider? currentImage;
  bool isEditMode = false;
  late Gender currentGender;
  late TextEditingController birthYearController;
  late TextEditingController caretakerController;
  late TextEditingController notesController;
  late TextEditingController heightController;

  @override
  void initState() {
    currentGender = widget.patient.gender;
    birthYearController = TextEditingController(text: widget.patient.dateOfBirth.year.toString());
    heightController = TextEditingController(text: (widget.patient.height ?? 0).toString());
    caretakerController = TextEditingController(text: widget.patient.caretakerName);
    notesController = TextEditingController(text: widget.patient.notes);

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
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 24.0),
                          Row(
                            children: [
                              Tooltip(
                                  child: Icon(chosenIcon(widget.patient), size: 32, color: Colors.blueAccent),
                                  message: 'gender'.tr()),
                              SizedBox(width: 16,), isEditMode? DropdownButton<Gender>(
                                value: currentGender,
                                icon: const Icon(Icons.arrow_drop_down_sharp),
                                onChanged: (Gender? changeGender) {
                                  setState(() {
                                    if (changeGender != null) {
                                      currentGender = changeGender;
                                    }
                                  });
                                },
                                items: Gender.values.map<DropdownMenuItem<Gender>>((Gender value) {
                                  return DropdownMenuItem<Gender>(
                                    value: value,
                                    child: Text(value.returnString),
                                  );
                                }).toList(),
                              ):
                              Text(widget.patient.gender.returnString, style: TextStyle(fontSize: 24, color: Colors.black45),),
                            ],
                          ),
                          SizedBox(height: 16,),
                          Row(
                            children: [
                              Tooltip(
                                  child: Icon(Icons.cake, size: 32, color: Colors.blueAccent,),
                                  message: 'birth_year'.tr()),
                              SizedBox(width: 16,), isEditMode?
                              Flexible(child: TextField(controller: birthYearController, keyboardType: TextInputType.number,)):
                              Text(widget.patient.dateOfBirth.year.toString(), style: TextStyle(fontSize: 24, color: Colors.black45,)),
                            ],
                          ),
                          SizedBox(height: 16,),
                          Row(
                            children: [
                              Tooltip(
                                  child: Icon(Icons.man, size: 32, color: Colors.blueAccent,),
                                  message: 'height'.tr()),
                              SizedBox(width: 16,), isEditMode?
                              Flexible(child: TextField(controller: heightController, keyboardType: TextInputType.number,)):
                              Text((widget.patient.height ?? 0).toString(), style: TextStyle(fontSize: 24, color: Colors.black45,)),
                            ],
                          ),
                          SizedBox(height: 16,),
                          Row(
                            children: [
                              Tooltip(
                                  child: Icon(Icons.assignment_ind, size: 32, color: Colors.blueAccent,),
                                  message: 'caretaker_name'.tr()),
                              SizedBox(width: 16,), isEditMode?
                              Flexible(child: TextField(controller: caretakerController)):
                              Flexible(child: Text(widget.patient.caretakerName, style: TextStyle(fontSize: 24, color: Colors.black45),)),
                            ],
                          ),
                          SizedBox(height: 16,),
                          Row(
                            children: [
                              Tooltip(
                                  child: Icon(Icons.notes, size: 32, color: Colors.blueAccent,),
                                  message: 'notes'.tr()),
                              SizedBox(width: 16,), isEditMode?
                              Flexible(child: TextField(controller: notesController)):
                              Flexible(child: Text(widget.patient.notes ?? '', style: TextStyle(fontSize: 24, color: Colors.black45),)),
                            ],
                          ),
                        ],
                      ),
                      Align(alignment: Alignment.topRight, child: 
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(child: IconButton(icon: Icon(Icons.cancel_outlined, color: Colors.redAccent,), onPressed: (){
                            setState(() {
                              isEditMode = false;
                              currentGender = widget.patient.gender;
                            });
                          },), visible: isEditMode,),
                          IconButton(icon: isEditMode? Icon(Icons.check, color: Colors.green,):Icon(Icons.edit), onPressed: (){
                            final dateOfBirthError = dateOfBirthValidator(birthYearController.text);
                            if (dateOfBirthError != null){
                              birthYearController.text = widget.patient.dateOfBirth.year.toString();
                              showDialog(context: context, builder: (context){
                                return AlertDialog(title: Text(dateOfBirthError), actions: [ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text('Ok'))],);
                              });
                            }
                            else{
                              if (caretakerController.text.isEmpty) {
                                caretakerController.text = widget.patient.caretakerName;
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(title: Text('incorrect_caretaker_name'.tr()), actions: [ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text('Ok'))],);
                                });
                              }
                              else {
                                if (heightController.text.isEmpty || int.parse(heightController.text) < 0) {
                                  heightController.text = widget.patient.height.toString();
                                  showDialog(context: context, builder: (context){
                                    return AlertDialog(title: Text('incorrect_height'.tr()), actions: [ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text('Ok'))],);
                                  });
                                }
                                else{
                                  setState(() {
                                    isEditMode = !isEditMode;
                                    widget.patient.gender = currentGender;
                                    widget.patient.dateOfBirth = DateTime(int.parse(birthYearController.text));
                                    widget.patient.height = int.parse(heightController.text);
                                    widget.patient.caretakerName = caretakerController.text;
                                    widget.patient.notes = notesController.text;
                                    widget.onPatientChange(widget.patient);
                                    currentGender = widget.patient.gender;
                                  });
                                }
                              }
                            }
                            },),
                        ],
                      ),),
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
    dateOfBirthValidator(String? value) {
      if (value == null || value.isEmpty) {
        return 'required'.tr();
      }
      else if (int.parse(value) < (DateTime.now().year + 543) - 100 || int.parse(value) > DateTime.now().year + 543) {
        print(value);
        return 'incorrect_input'.tr();
      }
      else {
        return null;
      }
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
