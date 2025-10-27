import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';
import 'package:http/http.dart' as http;

/// Deze proxy omzeilt CORS door fetch() via JavaScript uit te voeren.
/// Werkt alleen in Flutter Web, en is supersnel.
class LocalProxy {
  static Future<String> fetchDirect(String url) async {
    try {
      final jsFetch = html.window.fetch(url);
      final response = await jsFetch;
      final text = await response.text();
      return text;
    } catch (e) {
      print("⚠️ JS Fetch mislukt: $e");
      return '';
    }
  }

  /// Automatisch de juiste route bepalen (Web vs. mobiel)
  static Future<String> wrapUrl(String url) async {
    return url; // Op mobiel doen we niets bijzonders
  }

  /// Universele fetch voor M3U-bestanden (werkt ook bij CORS)
  static Future<List<String>> loadM3U(String url) async {
    try {
      String rawData = await fetchDirect(url);
      if (rawData.isEmpty) {
        // Fallback via proxy
        final proxied =
            'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
        final resp = await http.get(Uri.parse(proxied));
        rawData = utf8.decode(resp.bodyBytes);
      }

      return const LineSplitter().convert(rawData);
    } catch (e) {
      print('❌ Fout bij ophalen M3U: $e');
      return [];
    }
  }
}
