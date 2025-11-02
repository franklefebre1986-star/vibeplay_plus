import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'models/m3u_entry.dart';

class M3UProvider {
  /// 🧩 Laadt en parse't een M3U playlist (met fallback & proxy)
  static Future<List<M3UEntry>> loadM3U(String url) async {
    try {
      // ✅ Voeg CORS proxy toe op web
      if (kIsWeb && !url.startsWith('https://corsproxy.io/?')) {
        url = 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      }

      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/120.0 Safari/537.36',
        'Accept': '*/*',
        'Connection': 'keep-alive',
      };

      // ⏳ Eerste poging
      final response =
          await http.get(Uri.parse(url), headers: headers).timeout(
                const Duration(seconds: 10),
                onTimeout: () => http.Response('Timeout', 408),
              );

      if (response.statusCode != 200) {
        // 🔁 Tweede poging met TS fallback
        if (url.contains('output=m3u8')) {
          final fallbackUrl = url.replaceAll('output=m3u8', 'output=ts');
          final retry = await http
              .get(Uri.parse(fallbackUrl), headers: headers)
              .timeout(const Duration(seconds: 10),
                  onTimeout: () => http.Response('Timeout', 408));

          if (retry.statusCode == 200) {
            return _parseM3U(retry.bodyBytes);
          }
        }
        throw Exception('Serverfout (${response.statusCode})');
      }

      return _parseM3U(response.bodyBytes);
    } catch (e) {
      throw Exception("Fout bij laden: $e");
    }
  }

  /// 📄 Parse helper
  static List<M3UEntry> _parseM3U(List<int> bytes) {
    final body = utf8.decode(bytes);
    if (!body.contains("#EXTM3U")) {
      throw Exception("Geen geldige M3U-link gevonden.");
    }

    final lines = const LineSplitter().convert(body);
    final entries = <M3UEntry>[];
    String? title;
    String? logo;

    for (final line in lines) {
      if (line.startsWith("#EXTINF")) {
        final nameMatch = RegExp(r'tvg-name="(.*?)"').firstMatch(line);
        final logoMatch = RegExp(r'tvg-logo="(.*?)"').firstMatch(line);
        title = nameMatch?.group(1) ?? line.split(",").last.trim();
        logo = logoMatch?.group(1);
      } else if (line.startsWith("http")) {
        entries.add(M3UEntry(
          title: title ?? "Onbekend kanaal",
          logoUrl: logo,
          streamUrl: line.trim(),
        ));
        title = null;
        logo = null;
      }
    }

    if (entries.isEmpty) {
      throw Exception("Geen kanalen gevonden in M3U.");
    }

    return entries;
  }
}
