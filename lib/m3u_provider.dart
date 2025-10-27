import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/m3u_entry.dart';

class M3UProvider {
  static Future<List<M3UEntry>> loadM3U(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("❌ M3U download mislukt (${response.statusCode})");
    }

    // ✅ Probeer UTF-8, anders fallback naar Windows-1252
    String body;
    try {
      body = utf8.decode(response.bodyBytes);
    } catch (_) {
      body = latin1.decode(response.bodyBytes);
    }

    // ✅ Verwijder vreemde karakters
    body = body
        .replaceAll(RegExp(r'[^\x00-\x7F]+'), '')
        .replaceAll('â', "'")
        .replaceAll('â', '-')
        .replaceAll('Ã©', 'é')
        .replaceAll('Ã', 'A');

    final lines = const LineSplitter().convert(body);
    final entries = <M3UEntry>[];

    String? title;
    String? logo;
    String? country;

    for (final line in lines) {
      if (line.startsWith('#EXTINF:')) {
        final info = line.split(',');
        title = _cleanTitle(info.last.trim());

        final logoMatch = RegExp(r'tvg-logo="([^"]+)"').firstMatch(line);
        final countryMatch = RegExp(r'tvg-country="([^"]+)"').firstMatch(line);

        logo = logoMatch?.group(1);
        country = countryMatch?.group(1);
      } else if (line.startsWith('http')) {
        if (title != null && title.isNotEmpty) {
          entries.add(M3UEntry(
            title: title,
            streamUrl: line.trim(),
            logoUrl: logo,
            country: country,
          ));
        }
        title = logo = country = null;
      }
    }

    return entries;
  }

  /// 🧠 Slimme titelopschoning
  static String _cleanTitle(String title) {
    return title
        .replaceAll(RegExp(r'16K|8K|4K|2K|HD|FHD|UHD|SD|NL|BE|DE', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('|', '')
        .trim();
  }
}
