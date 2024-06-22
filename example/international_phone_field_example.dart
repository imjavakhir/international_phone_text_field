import 'package:flutter/material.dart';
import 'package:international_phone_text_field/src/international_phone_text_field_base.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('International Phone Text Field Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InternationalPhoneTextField(
              onChanged: (number) {},
              inOneLine: true,
            ),
          ],
        ),
      ),
    );
  }
}
