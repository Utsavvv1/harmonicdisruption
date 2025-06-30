import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/monitor_service.dart';
import '../services/config_service.dart';
import '../services/firebase_service.dart';
import 'edit_list_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _monitoring = false;
  String? _userId;
  final MonitorService _monitorService = MonitorService();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _setMinWindowSize();
    _startAutoFocusMonitor();
  }

  Future<void> _loadUserId() async {
    final id = await ConfigService.getOrCreateUserId();
    setState(() {
      _userId = id;
    });
  }

  void _setMinWindowSize() async {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(700, 600));
  }

  void _startAutoFocusMonitor() {
    Future.doWhile(() async {
      final focus = await MonitorService.isFocusAppActive();
      setState(() {
        _monitoring = focus;
      });
      await FirebaseService.setFocusState(focus);
      await Future.delayed(const Duration(seconds: 2));
      return mounted;
    });
  }

  void _editWhitelist() async {
    final whitelist = await ConfigService.loadWhitelist();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditListScreen(
              title: 'Edit Work Apps',
              initialList: whitelist,
              onSave: (list) async {
                await ConfigService.saveWhitelist(list);
                setState(() {});
              },
            ),
      ),
    );
  }

  void _editBlacklist() async {
    final blacklist = await ConfigService.loadBlacklist();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditListScreen(
              title: 'Edit Distractions',
              initialList: blacklist,
              onSave: (list) async {
                await ConfigService.saveBlacklist(list);
                setState(() {});
              },
            ),
      ),
    );
  }

  void _exitApp() async {
    _monitorService.stopMonitoring();
    setState(() {
      _monitoring = false;
    });
    await FirebaseService.setFocusState(false);
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = MediaQuery.of(context).size.width;
    double baseHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A171A), Color(0xFF201E40)],
              stops: [0.75, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: baseHeight * 0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header (logo only)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: baseWidth * 0.06),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: baseWidth * 0.13,
                          height: baseHeight * 0.05,
                          child: Image.asset(
                            'assets/synapse_logo.png',
                            color: const Color(0xFFF4EAEA),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main Content
                  Column(
                    children: [
                      // ID Section
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: baseHeight * 0.05,
                          horizontal: baseWidth * 0.03,
                        ),
                        child: Column(
                          children: [
                            // User ID
                            GestureDetector(
                              onTap: () {
                                if (_userId != null) {
                                  Clipboard.setData(
                                    ClipboardData(text: _userId!),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied ID to clipboard!'),
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Text(
                                    _userId ?? 'Loading...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: baseWidth * 0.055,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.white.withOpacity(0.69),
                                          blurRadius: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: baseHeight * 0.01),
                                  const Text(
                                    'Your Unique ID',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Montserrat',
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 3,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: baseHeight * 0.03),
                            // Note Box
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: baseHeight * 0.012,
                                horizontal: baseWidth * 0.08,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF464646).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(29),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.26),
                                    blurRadius: 30,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Enter this on your phone to sync with your PC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Montserrat',
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit Buttons
                      Padding(
                        padding: EdgeInsets.only(
                          top: baseHeight * 0.01,
                          bottom: baseHeight * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _editWhitelist,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF769AFF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 32,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(49),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                ),
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.26),
                              ),
                              child: const Text('Edit Work Apps'),
                            ),
                            SizedBox(width: 15),
                            ElevatedButton(
                              onPressed: _editBlacklist,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF362DB7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 32,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(49),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                ),
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.26),
                              ),
                              child: const Text('Edit Distractions'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Focus Status
                  Padding(
                    padding: EdgeInsets.only(bottom: baseHeight * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Focus Mode : ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: baseWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.29),
                                blurRadius: 30,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _monitoring ? 'ON' : 'OFF',
                          style: TextStyle(
                            color:
                                _monitoring
                                    ? const Color(0xFF6C64E9)
                                    : const Color(0xFFE0E0E0),
                            fontSize: baseWidth * 0.035,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.29),
                                blurRadius: 30,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: baseWidth * 0.02),
                          width: baseWidth * 0.018,
                          height: baseWidth * 0.018,
                          decoration: BoxDecoration(
                            color:
                                _monitoring
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFFF6B6B),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    _monitoring
                                        ? const Color(
                                          0xFF4CAF50,
                                        ).withOpacity(0.6)
                                        : const Color(
                                          0xFFFF6B6B,
                                        ).withOpacity(0.6),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Exit
                  Padding(
                    padding: EdgeInsets.only(bottom: baseHeight * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _exitApp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 32,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(49),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.26),
                          ),
                          child: const Text('Exit Synapse'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
