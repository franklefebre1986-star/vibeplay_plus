import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LogoCacheManager {
  static Future<String> getLogo(String name, String url) async {
    try {
      if (url.isEmpty) return "";

      final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
      final ext = url.endsWith('.svg') ? 'svg' : 'png';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$safeName.$ext');

      if (await file.exists()) return file.path;

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      print('⚠️ LogoCache fout: $e');
    }
    return "";
  }
}
