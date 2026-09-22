import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_page.dart';

class IndoorNavApp extends StatelessWidget {
  const IndoorNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndoorNav',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}