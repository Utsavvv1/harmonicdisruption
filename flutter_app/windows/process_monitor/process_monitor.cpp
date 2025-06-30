// process_monitor.cpp
// Native Windows code for process listing and killing

#include <windows.h>
#include <tlhelp32.h>
#include <vector>
#include <string>
#include <cwchar>
#include <psapi.h>

// Helper: Get all process names
std::vector<std::wstring> get_process_names() {
    std::vector<std::wstring> names;
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnapshot == INVALID_HANDLE_VALUE) return names;
    PROCESSENTRY32W pe;
    pe.dwSize = sizeof(PROCESSENTRY32W);
    if (Process32FirstW(hSnapshot, &pe)) {
        do {
            names.push_back(pe.szExeFile);
        } while (Process32NextW(hSnapshot, &pe));
    }
    CloseHandle(hSnapshot);
    return names;
}

// Export: Write comma-separated process names to buffer
extern "C" __declspec(dllexport) int list_processes(wchar_t* buffer, int max_len) {
    auto names = get_process_names();
    std::wstring joined;
    for (size_t i = 0; i < names.size(); ++i) {
        joined += names[i];
        if (i + 1 < names.size()) joined += L",";
    }
    if ((int)joined.size() >= max_len) return -1;
    wcsncpy_s(buffer, max_len, joined.c_str(), _TRUNCATE);
    return (int)names.size();
}

// Export: Kill all processes with given name
extern "C" __declspec(dllexport) int kill_process(const wchar_t* process_name) {
    int killed = 0;
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnapshot == INVALID_HANDLE_VALUE) return 0;
    PROCESSENTRY32W pe;
    pe.dwSize = sizeof(PROCESSENTRY32W);
    if (Process32FirstW(hSnapshot, &pe)) {
        do {
            if (_wcsicmp(pe.szExeFile, process_name) == 0) {
                HANDLE hProc = OpenProcess(PROCESS_TERMINATE, FALSE, pe.th32ProcessID);
                if (hProc) {
                    if (TerminateProcess(hProc, 1)) ++killed;
                    CloseHandle(hProc);
                }
            }
        } while (Process32NextW(hSnapshot, &pe));
    }
    CloseHandle(hSnapshot);
    return killed;
}

// Export: Get the process name of the foreground window
extern "C" __declspec(dllexport) int get_foreground_process(wchar_t* buffer, int max_len) {
    HWND hwnd = GetForegroundWindow();
    if (!hwnd) return 0;
    DWORD pid = 0;
    GetWindowThreadProcessId(hwnd, &pid);
    if (!pid) return 0;
    HANDLE hProc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
    if (!hProc) return 0;
    wchar_t exeName[MAX_PATH] = {0};
    HMODULE hMod;
    DWORD cbNeeded;
    if (EnumProcessModules(hProc, &hMod, sizeof(hMod), &cbNeeded)) {
        GetModuleBaseNameW(hProc, hMod, exeName, MAX_PATH);
        wcsncpy_s(buffer, max_len, exeName, _TRUNCATE);
        CloseHandle(hProc);
        return 1;
    }
    CloseHandle(hProc);
    return 0;
} 