import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

final Map<String, DateTime> _promptCooldowns = HashMap();
const Duration _cooldownDuration = Duration(seconds: 2);

Future<PromptResult?> showPromptDialog(
  BuildContext context,
  String appName,
) async {
  // 1) Save original window state
  final originalBounds = await windowManager.getBounds();
  final originalAlwaysOnTop = await windowManager.isAlwaysOnTop();
  final wasVisible = await windowManager.isVisible();

  // 2) Hide your main window
  if (wasVisible) await windowManager.hide();

  // 3) Make this prompt-window completely frameless & transparent
  await windowManager.setHasShadow(false);
  await windowManager.setBackgroundColor(Colors.transparent);
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

  // 4) Size & center it
  const promptSize = Size(320, 160);
  final display = await screenRetriever.getPrimaryDisplay();
  final screenCenter = Offset(
    (display.size.width - promptSize.width) / 2,
    (display.size.height - promptSize.height) / 2,
  );
  await windowManager.setSize(promptSize);
  await windowManager.setPosition(screenCenter);

  // 5) Always on top, show & focus
  await windowManager.setAlwaysOnTop(true);
  await windowManager.show();
  await windowManager.focus();

  // 6) Push your transparent-route overlay
  final result = await Navigator.of(context).push<PromptResult>(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, __, ___) => _PromptOverlay(appName: appName),
    ),
  );

  // 7) Restore everything
  await windowManager.setSize(originalBounds.size);
  await windowManager.setPosition(originalBounds.topLeft);
  await windowManager.setAlwaysOnTop(originalAlwaysOnTop);
  await windowManager.setTitleBarStyle(TitleBarStyle.normal);
  await windowManager.setBackgroundColor(const Color(0xFFFFFFFF));
  await windowManager.setHasShadow(true);
  await windowManager.restore();
  await Future.delayed(Duration(milliseconds: 100));
  await windowManager.show();
  await windowManager.focus();

  // 8) Cooldown logic
  if (result != null) {
    final key = appName.toLowerCase();
    if (result.action == PromptAction.submit) {
      _promptCooldowns[key] = DateTime.now().add(_cooldownDuration);
    } else {
      _promptCooldowns.remove(key);
    }
    return result;
  }
  return null;
}

bool isAppInPromptCooldown(String appName) {
  final key = appName.toLowerCase();
  final until = _promptCooldowns[key];
  return until != null && DateTime.now().isBefore(until);
}

enum PromptAction { exit, submit }

class PromptResult {
  final PromptAction action;
  final String reason;
  PromptResult(this.action, this.reason);
}

class _PromptOverlay extends StatelessWidget {
  final String appName;
  const _PromptOverlay({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A171A).withOpacity(0.98),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6C64E9), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'HOLD UP!',
              style: TextStyle(
                color: Color(0xFFF4EAEA),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Why are you opening $appName?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontFamily: 'Montserrat',
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type here',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 11),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pop(PromptResult(PromptAction.exit, '')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C64E9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    child: const Text('EXIT'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.of(context).pop(
                          PromptResult(
                            PromptAction.submit,
                            controller.text.trim(),
                          ),
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF362DB7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    child: const Text('SUBMIT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void setAppPromptCooldown(String appName) {
  final key = appName.toLowerCase();
  _promptCooldowns[key] = DateTime.now().add(_cooldownDuration);
}

Duration getPromptCooldownDuration() => _cooldownDuration;
