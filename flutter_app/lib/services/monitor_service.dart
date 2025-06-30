import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/prompt_dialog.dart';
import 'config_service.dart';
import 'firebase_service.dart';
import 'process_monitor_ffi.dart';

// UNIQUE_PRINT_1: File loaded
void _uniqueMonitorServiceFileLoaded() {
  print('UNIQUE_MONITOR_SERVICE_FILE_LOADED_12345');
}

final _ = _uniqueMonitorServiceFileLoaded();

class MonitorService {
  // UNIQUE_PRINT_2: Class loaded
  static final _uniqueClassLoaded =
      (() {
        print('UNIQUE_MONITOR_SERVICE_CLASS_LOADED_ABCDE');
        return true;
      })();

  Timer? _timer;
  bool monitoring = false;
  String? _lastPromptedApp;
  final Map<String, Timer> _temporaryUnblacklistTimers = {};
  final Set<String> _appsWithOpenPrompt = {};

  MonitorService() {
    print('UNIQUE_MONITOR_SERVICE_CONSTRUCTOR_CALLED_99999');
  }

  void startMonitoring(BuildContext context) {
    print('UNIQUE_PRINT_3: startMonitoring called');
    monitoring = true;
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _poll(context),
    );
  }

  void stopMonitoring() {
    print('UNIQUE_PRINT_4: stopMonitoring called');
    monitoring = false;
    _timer?.cancel();
    // Cancel all temporary unblacklist timers
    for (final timer in _temporaryUnblacklistTimers.values) {
      timer.cancel();
    }
    _temporaryUnblacklistTimers.clear();
  }

  Future<void> _poll(BuildContext context) async {
    final allProcsOriginal = ProcessMonitor.listProcesses();
    final allProcs =
        allProcsOriginal.map((e) => e.trim().toLowerCase()).toList();
    final whitelist =
        (await ConfigService.loadWhitelist())
            .map((e) => e.trim().toLowerCase())
            .toList();
    final blacklist =
        (await ConfigService.loadBlacklist())
            .map((e) => e.trim().toLowerCase())
            .toList();
    // Check if any whitelist app is running (in allProcs)
    bool anyWhitelistRunning = allProcs.any((proc) => whitelist.contains(proc));
    // Set focus mode state based on whitelist presence
    await FirebaseService.setFocusState(anyWhitelistRunning);
    if (!anyWhitelistRunning) {
      return;
    }
    // For every blacklisted process running, show popup (if not already prompted and not in cooldown)
    for (int i = 0; i < allProcs.length; i++) {
      final proc = allProcs[i];
      if (blacklist.contains(proc)) {
        final originalProc = allProcsOriginal[i];
        if (isAppInPromptCooldown(proc) || _appsWithOpenPrompt.contains(proc))
          continue;
        _appsWithOpenPrompt.add(proc);
        final result = await showPromptDialog(context, originalProc);
        _appsWithOpenPrompt.remove(proc);
        if (result == null || result.action == PromptAction.exit) {
          ProcessMonitor.killProcess(originalProc);
          setAppPromptCooldown(proc);
        } else if (result.action == PromptAction.submit) {
          await FirebaseService.sendDistractionEvent(
            originalProc,
            result.reason,
          );
          await _temporarilyRemoveFromBlacklist(
            proc,
            Duration(minutes: 10),
            context,
          );
        }
      }
    }
  }

  Future<void> _temporarilyRemoveFromBlacklist(
    String proc,
    Duration duration,
    BuildContext context,
  ) async {
    final blacklist =
        (await ConfigService.loadBlacklist())
            .map((e) => e.trim().toLowerCase())
            .toList();
    if (!blacklist.contains(proc)) return;
    // Remove from blacklist
    blacklist.remove(proc);
    await ConfigService.saveBlacklist(blacklist);
    // Set timer to add back after duration
    _temporaryUnblacklistTimers[proc]?.cancel();
    _temporaryUnblacklistTimers[proc] = Timer(duration, () async {
      final currentBlacklist =
          (await ConfigService.loadBlacklist())
              .map((e) => e.trim().toLowerCase())
              .toList();
      if (!currentBlacklist.contains(proc)) {
        currentBlacklist.add(proc);
        await ConfigService.saveBlacklist(currentBlacklist);
        // No need to set _lastPromptedApp anymore
      }
      _temporaryUnblacklistTimers.remove(proc);
    });
  }

  static Future<bool> isFocusAppActive() async {
    final allProcs = ProcessMonitor.listProcesses();
    final whitelist =
        (await ConfigService.loadWhitelist())
            .map((e) => e.toLowerCase())
            .toList();
    // Return true if ANY whitelisted process is running
    return allProcs
        .map((e) => e.toLowerCase())
        .any((proc) => whitelist.contains(proc));
  }
}

// UNIQUE_PRINT_28: End of file
