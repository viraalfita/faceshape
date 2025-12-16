import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/face_shape_provider.dart';
import 'providers/history_provider.dart';
import 'screens/splash_screen.dart';

// main.dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FaceShapeProvider()),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider()..loadHistory(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaceShape & Style',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
    );
  }
}
