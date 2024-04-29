import 'package:flutter/material.dart';
import 'package:klaar_gemini/pages/constrait.dart';
import 'package:klaar_gemini/pages/gemini_chat_page.dart';

import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  Gemini.init(apiKey: gemini_token);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      home: const GeminiChat(),
    );
  }
}
