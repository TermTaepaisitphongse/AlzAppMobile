import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class MyApp extends StatelessWidget {
  final String stringLocale;

  const MyApp({Key? key, required this.stringLocale}) : super(key: key);

  // #docregion build
  @override
  Widget build(BuildContext context) {
    Locale locale;
    if (stringLocale == "US") {
      locale = Locale('en', 'US');
    } else {
      locale = Locale('th', 'TH');
    }
    print(locale);
    return MaterialApp(
      title: 'AlzApp Health Records',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: SettingsPage(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: locale,
    );
  }
// #enddocregion build
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String dropdownValue = 'English (US)';
  Icon icon = Icon(Icons.eighteen_mp);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: Container(
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
          child: Material(
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
                    print(Text('$newValue'));
                    if (newValue == 'language_english'.tr()) {
                      dropdownValue = 'language_english'.tr();
                      icon = Icon(Icons.eighteen_mp);
                      EasyLocalization.of(context)
                          ?.setLocale(Locale('en', 'US'));
                    } else if (newValue == 'language_thai'.tr()) {
                      dropdownValue = 'language_thai'.tr();
                      icon = Icon(Icons.cancel_outlined);
                      EasyLocalization.of(context)
                          ?.setLocale(Locale('th', 'TH'));
                    }
                  });
                },
                items: <String>['language_english'.tr(), 'language_thai'.tr()]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 3),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          )),
        ),
      ),
    );
  }
}

//create function for changing calendar system (on main page), add dropdown above
