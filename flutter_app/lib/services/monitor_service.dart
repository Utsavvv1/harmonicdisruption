import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/prompt_dialog.dart';
import 'config_service.dart';
import 'firebase_service.dart';
import 'process_monitor_ffi.dart';

class MonitorService {
  Timer? _timer;
  bool monitoring = false;
  String? _lastPromptedApp;

  void startMonitoring(BuildContext context) {
    monitoring = true;
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll(context));
  }

  void stopMonitoring() {
    monitoring = false;
    _timer?.cancel();
    _lastPromptedApp = null;
  }

  Future<void> _poll(BuildContext context) async {
    final fgApp = ProcessMonitor.getForegroundProcess();
    print('[Monitor] Foreground process: $fgApp');
    final whitelist =
        (await ConfigService.loadWhitelist())
            .map((e) => e.trim().toLowerCase())
            .toList();
    final blacklist =
        (await ConfigService.loadBlacklist())
            .map((e) => e.trim().toLowerCase())
            .toList();
    final allProcsOriginal = ProcessMonitor.listProcesses();
    final allProcs =
        allProcsOriginal.map((e) => e.trim().toLowerCase()).toList();
    print('[Monitor] All running processes: $allProcsOriginal');
    print('[Monitor] Whitelist: $whitelist');
    print('[Monitor] Blacklist: $blacklist');
    print('in _poll');
    if (fgApp == null) return;
    final fgAppLower = fgApp.trim().toLowerCase();
    final isFocusMode = whitelist.contains(fgAppLower);
    print('in _poll 2');
    // Manually parse all running processes and check for any blacklisted process
    for (int i = 0; i < allProcs.length; i++) {
      final proc = allProcs[i];
      // Debug print to show what is being compared
      print(
        'Comparing process: "' +
            proc +
            '" against blacklist: ' +
            blacklist.toString(),
      );
      if (blacklist.contains(proc)) {
        final originalProc = allProcsOriginal[i];
        print(
          '[Monitor] Distraction app detected: $originalProc (focus mode: $isFocusMode)',
        );
        // If in focus mode (work app in foreground), activate popup for each blacklisted process
        if (isFocusMode) {
          if (_lastPromptedApp == proc)
            continue; // Avoid repeat prompts for same app
          _lastPromptedApp = proc;
          final reason = await showPromptDialog(context, originalProc);
          print(
            '[Monitor] Popup shown for $originalProc, user reason: $reason',
          );
          if (reason == null || reason.isEmpty) {
            final killed = ProcessMonitor.killProcess(originalProc);
            print('❌ Killed $killed instance(s) of $originalProc');
          } else {
            await FirebaseService.sendDistractionEvent(originalProc, reason);
            print('✅ Allowed $originalProc with reason: $reason');
          }
        }
      }
    }
    // If not in focus mode, reset last prompted app
    if (!isFocusMode) {
      _lastPromptedApp = null;
    }
  }

  static Future<bool> isFocusAppActive() async {
    final fgApp = ProcessMonitor.getForegroundProcess();
    final allProcs = ProcessMonitor.listProcesses();
    final whitelist =
        (await ConfigService.loadWhitelist())
            .map((e) => e.toLowerCase())
            .toList();
    final blacklist =
        (await ConfigService.loadBlacklist())
            .map((e) => e.toLowerCase())
            .toList();
    print('[Monitor] Foreground process: $fgApp');
    print('asdasd');
    print('[Monitor] All running processes: $allProcs');
    print('[Monitor] Whitelist: $whitelist');
    print('[Monitor] Blacklist: $blacklist');
    if (fgApp == null) return false;
    return whitelist.contains(fgApp.toLowerCase());
  }
}
