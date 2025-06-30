import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI signatures
typedef ListProcessesC = Int32 Function(Pointer<Utf16> buffer, Int32 maxLen);
typedef ListProcessesDart = int Function(Pointer<Utf16> buffer, int maxLen);

typedef KillProcessC = Int32 Function(Pointer<Utf16> processName);
typedef KillProcessDart = int Function(Pointer<Utf16> processName);

typedef GetForegroundProcessC =
    Int32 Function(Pointer<Utf16> buffer, Int32 maxLen);
typedef GetForegroundProcessDart =
    int Function(Pointer<Utf16> buffer, int maxLen);

class ProcessMonitor {
  static final DynamicLibrary _lib = () {
    if (Platform.isWindows) {
      // Adjust path as needed
      return DynamicLibrary.open(
        'windows/process_monitor/build/Release/process_monitor.dll',
      );
    }
    throw UnsupportedError('Only supported on Windows');
  }();

  static final ListProcessesDart _listProcesses = _lib
      .lookupFunction<ListProcessesC, ListProcessesDart>('list_processes');
  static final KillProcessDart _killProcess = _lib
      .lookupFunction<KillProcessC, KillProcessDart>('kill_process');
  static final GetForegroundProcessDart _getForegroundProcess = _lib
      .lookupFunction<GetForegroundProcessC, GetForegroundProcessDart>(
        'get_foreground_process',
      );

  static List<String> listProcesses() {
    final buffer = calloc<Uint16>(8192);
    try {
      final count = _listProcesses(buffer.cast(), 8192);
      if (count < 0) return [];
      final result = buffer.cast<Utf16>().toDartString();
      return result.split(',').where((s) => s.isNotEmpty).toList();
    } finally {
      calloc.free(buffer);
    }
  }

  static int killProcess(String exeName) {
    final ptr = exeName.toNativeUtf16();
    try {
      return _killProcess(ptr);
    } finally {
      calloc.free(ptr);
    }
  }

  static String? getForegroundProcess() {
    final buffer = calloc<Uint16>(512);
    try {
      final ok = _getForegroundProcess(buffer.cast(), 512);
      if (ok == 1) {
        return buffer.cast<Utf16>().toDartString();
      }
      return null;
    } finally {
      calloc.free(buffer);
    }
  }
}
