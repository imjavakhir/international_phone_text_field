import 'package:flutter/material.dart';
import 'package:international_phone_field/international_phone_field.dart';

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
        title: const Text('International Phone Field Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InternationalPhoneField(
              onChanged: (text) {
                print(text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
