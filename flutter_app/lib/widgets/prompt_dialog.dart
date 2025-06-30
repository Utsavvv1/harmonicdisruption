import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:window_manager/window_manager.dart';

Future<String?> showPromptDialog(BuildContext context, String appName) async {
  final TextEditingController controller = TextEditingController();
  // Bring window to foreground and focus
  await windowManager.show();
  await windowManager.focus();
  await windowManager.setAlwaysOnTop(true);
  await windowManager.setFullScreen(false);
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setOpacity(0.98);

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // Dialog background color at the bottom
              Container(
                width: 340,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A171A).withOpacity(0.98),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.65),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF6C64E9), width: 1),
                ),
              ),
              // SVG overlay above background, sized to dialog
              Container(
                width: 340,
                height: null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SvgPicture.asset(
                    'assets/background_overlay.svg',
                    fit: BoxFit.cover,
                    width: 340,
                  ),
                ),
              ),
              // All content above SVG
              Container(
                width: 340,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'HOLD UP!',
                      style: TextStyle(
                        color: Color(0xFFF4EAEA),
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    SvgPicture.asset(
                      'assets/eyelogo.svg',
                      width: 45,
                      height: 32,
                      color: const Color(0xFFF4EAEA),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "You're currently in focus mode",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Montserrat',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'What is your motive to open $appName?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF353434),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: const Color(0xFF6C64E9),
                          width: 0.7,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type here',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C64E9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            child: const Text('EXIT'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                () => Navigator.of(
                                  context,
                                ).pop(controller.text.trim()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF362DB7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
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
            ],
          ),
        ),
      );
    },
  );

  // Restore window state
  await windowManager.setAlwaysOnTop(false);
  await windowManager.setTitleBarStyle(TitleBarStyle.normal);
  await windowManager.setOpacity(1.0);

  return result;
}

class PromptDialog extends StatelessWidget {
  final String appName;
  final void Function(String) onSubmit;
  final VoidCallback onExit;

  const PromptDialog({
    Key? key,
    required this.appName,
    required this.onSubmit,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    return Dialog(
      backgroundColor: const Color(0xFF1A171A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Stack(
          children: [
            // Dialog background color at the bottom
            Container(
              width: 340,
              decoration: BoxDecoration(
                color: const Color(0xFF1A171A).withOpacity(0.98),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.65),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFF6C64E9), width: 1),
              ),
            ),
            // SVG overlay above background, sized to dialog
            Container(
              width: 340,
              height: null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SvgPicture.asset(
                  'assets/background_overlay.svg',
                  fit: BoxFit.cover,
                  width: 340,
                ),
              ),
            ),
            // All content above SVG
            Container(
              width: 340,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'HOLD UP!',
                    style: TextStyle(
                      color: Color(0xFFF4EAEA),
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  SvgPicture.asset(
                    'assets/eyelogo.svg',
                    width: 45,
                    height: 32,
                    color: const Color(0xFFF4EAEA),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "You're currently in focus mode",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'What is your motive to open $appName?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF353434),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: const Color(0xFF6C64E9),
                        width: 0.7,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type here',
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_controller.text.trim().isNotEmpty) {
                              onSubmit(_controller.text.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C64E9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 17,
                              horizontal: 44,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(49),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                            elevation: 8,
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: onExit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 17,
                        horizontal: 44,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(49),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                      elevation: 8,
                    ),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
