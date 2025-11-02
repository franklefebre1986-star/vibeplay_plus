import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// 🔍 Vindt en toont het juiste logo op basis van de kanaalnaam.
class LogoResolver {
  static Map<String, String>? _logos;

  /// Laad de JSON met logo's uit assets (eenmalig gecachet)
  static Future<void> _loadLogos() async {
    if (_logos != null) return;
    try {
      final data = await rootBundle.loadString('assets/logos.json');
      final jsonMap = json.decode(data) as Map<String, dynamic>;
      _logos = jsonMap.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
    } catch (e) {
      debugPrint("⚠️ Fout bij laden van logos.json: $e");
      _logos = {};
    }
  }

  /// Bouwt een logo-widget (of een standaard TV-icoon)
  static Future<Widget> buildLogo(String title,
      {String? country, double size = 60}) async {
    await _loadLogos();

    final key = title.toLowerCase().trim();
    final match = _logos!.entries.firstWhere(
      (e) => key.contains(e.key),
      orElse: () => const MapEntry('', ''),
    );

    if (match.value.isNotEmpty) {
      return Image.asset(
        'assets/logos/${match.value}',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    } else {
      return Icon(Icons.tv, color: Colors.white70, size: size);
    }
  }
}
