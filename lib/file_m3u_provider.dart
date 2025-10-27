import 'dart:convert';
import 'dart:html' as html;
import 'models/m3u_entry.dart';

class FileM3UProvider {
  static Future<List<M3UEntry>> pickAndParse() async {
    try {
      final uploadInput = html.FileUploadInputElement()..accept = '.m3u';
      uploadInput.click();

      await uploadInput.onChange.first;
      final file = uploadInput.files?.first;
      if (file == null) return [];

      final reader = html.FileReader();
      reader.readAsText(file);
      await reader.onLoad.first;

      final content = reader.result as String;
      return _parseM3U(content);
    } catch (e) {
      print('❌ Fout bij laden lokaal M3U-bestand: $e');
      return [];
    }
  }

  static List<M3UEntry> _parseM3U(String content) {
    final lines = const LineSplitter().convert(content);
    final entries = <M3UEntry>[];

    String? title;
    String? logo;
    String? country;

    for (var line in lines) {
      if (line.startsWith('#EXTINF:')) {
        final info = line.split(',');
        title = info.last.trim();

        final logoMatch = RegExp(r'tvg-logo="([^"]+)"').firstMatch(line);
        final countryMatch = RegExp(r'tvg-country="([^"]+)"').firstMatch(line);

        logo = logoMatch?.group(1);
        country = countryMatch?.group(1);
      } else if (line.startsWith('http')) {
        if (title != null) {
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
}
