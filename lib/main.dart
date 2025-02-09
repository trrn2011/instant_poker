import 'package:flutter/material.dart';
import 'screens/top_screen.dart';
import 'package:provider/provider.dart';
import 'providers/game_setting_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameSettingProvider()),
        // 他のProvider...
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TopScreen(),
    );
  }
}
