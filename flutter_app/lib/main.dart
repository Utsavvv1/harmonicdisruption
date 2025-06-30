import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
// import 'screens/edit_list_screen.dart';
// import 'widgets/prompt_dialog.dart';
// import 'services/config_service.dart';
// import 'services/process_monitor_ffi.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  runApp(const HarmonicDisruptionApp());
}

class HarmonicDisruptionApp extends StatelessWidget {
  const HarmonicDisruptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synapse – Focus Monitor',
      theme: ThemeData(
        primaryColor: const Color(0xFF362DB7),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF6C64E9),
          background: const Color(0xFFF4EAEA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4EAEA),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF1A171A)),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
