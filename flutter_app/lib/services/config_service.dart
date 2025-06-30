import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class ConfigService {
  static const String whitelistKey = 'allowed_apps';
  static const String blacklistKey = 'distraction_apps';
  static const String userIdKey = 'user_id';

  static const List<String> defaultWhitelist = [
    'Notion.exe',
    'Code.exe',
    'Word.exe',
    'Excel.exe',
    'PowerPoint.exe',
    'Acrobat.exe',
    'obsidian.exe',
    'pycharm64.exe',
    'idea64.exe',
    'chrome.exe',
    'firefox.exe',
    'Postman.exe',
    'Teams.exe',
    'Zoom.exe',
    'OneNote.exe',
    'Outlook.exe',
  ];

  static const List<String> defaultBlacklist = [
    'YouTube.exe',
    'Discord.exe',
    'Instagram.exe',
    'WhatsApp.exe',
    'Telegram.exe',
    'Snapchat.exe',
    'Netflix.exe',
    'Facebook.exe',
    'Reddit.exe',
    'Steam.exe',
    'Valorant.exe',
    'EpicGamesLauncher.exe',
    'robloxplayerbeta.exe',
    'Twitch.exe',
    'TikTok.exe',
    'OperaGX.exe',
    'Messenger.exe',
    'VLC.exe',
    'CrabGame.exe',
    'LeagueClient.exe',
    'Spotify.exe',
  ];

  static Future<List<String>> loadWhitelist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(whitelistKey) ?? defaultWhitelist;
  }

  static Future<List<String>> loadBlacklist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(blacklistKey) ?? defaultBlacklist;
  }

  static Future<void> saveWhitelist(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(whitelistKey, list);
  }

  static Future<void> saveBlacklist(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(blacklistKey, list);
  }

  static Future<String> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(userIdKey);
    if (userId != null && userId.isNotEmpty) return userId;
    userId = _generateUserId();
    await prefs.setString(userIdKey, userId);
    return userId;
  }

  static String _generateUserId({int length = 8}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
