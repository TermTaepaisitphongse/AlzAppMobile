import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String dropdownValue = 'English - UK' as String;
  Icon icon = Icons.eighteen_mp as Icon;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(top: 50),
      width: width,
      alignment: Alignment.center,
      child: Container(
        height: 40,
        padding: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.black, width: .9),
        ),
        child: Container(
            padding: EdgeInsets.only(left: 4, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButton<String>(
                  icon: Container(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: icon,
                    height: 30,
                    width: 30,
                  ),
                  iconSize: 18,
                  elevation: 16,
                  value: dropdownValue,
                  style: TextStyle(color: Colors.black),
                  underline: Container(
                    padding: EdgeInsets.only(left: 4, right: 4),
                    color: Colors.transparent,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue == 'language_english'.tr()) {
                        this.setState(() {
                          dropdownValue = 'language_english'.tr() as String;
                          icon = Icons.eighteen_mp as Icon;
                          context.setLocale(Locale('en', 'US'));
                        });
                      } else if (newValue == 'language_thai'.tr()) {
                        this.setState(() {
                          dropdownValue = 'language_thai'.tr() as String;
                          icon = Icons.cancel_outlined as Icon;
                          context.setLocale(Locale('th', 'TH'));
                        });
                      }
                    });
                  },
                  items: <String>['language_english'.tr(), 'language_thai'.tr()]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Container(
                  margin: EdgeInsets.only(left: 3),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                  ),
                )
              ],
            )),
      ),
    );
  }
}
