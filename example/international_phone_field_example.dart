import 'package:flutter/material.dart';
import 'package:international_phone_text_field/src/international_phone_text_field_base.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FocusNode phoneFocus = FocusNode();
  bool hasFocus = false;

  @override
  void initState() {
    phoneFocus.addListener(() {
      if (phoneFocus.hasFocus) {
        hasFocus = true;
      } else {
        hasFocus = false;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('International Phone Text Field Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Focus(
                focusNode: phoneFocus,
                child: InternationalPhoneTextField(
                  cursorColor: Color(0xff077E94),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: hasFocus ? Color(0xff077E94) : Colors.white),
                      borderRadius: BorderRadius.circular(8),
                      color: hasFocus ? Colors.white : Color(0xffF5F9FA)),
                  onChanged: (number) {},
                  inOneLine: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
