import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'main.dart';

void main() => runApp(MyApp());

// #docregion MyApp
class MyApp extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    Patient patient = Patient(name: 'name', caretakerName: 'caretakerName', color: Colors.white);
    return MaterialApp(
      title: 'AlzApp Health Records',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: BloodPressureItem()),
    );
  }
// #enddocregion build
}

class BloodPressureItem extends StatelessWidget {
  const BloodPressureItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              Text('Pressure', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, ),),
              SizedBox(width: 16.0),
              Icon(Icons.favorite_outline_outlined),
            ],
            mainAxisSize: MainAxisSize.min,
          ),
          SizedBox(height: 8.0,),
          Text('hi2', style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold)),
        ],
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ),
      color: Colors.greenAccent,
      borderRadius: BorderRadius.circular(16.0),
      elevation: 4,
    );
  }
}
