import 'dart:convert';
import 'dart:io';

/// 🔥 Logo Generator Script for VibePlay+
/// Scant de map assets/logos/ en genereert assets/logos.json.
///
/// Run dit commando:
/// flutter pub run tool/logo_generator.dart

void main() async {
  final logosDir = Directory('assets/logos');
  final outputFile = File('assets/logos.json');

  if (!await logosDir.exists()) {
    print('❌ Map assets/logos niet gevonden.');
    exit(1);
  }

  final Map<String, String> logos = {};

  await for (final entity in logosDir.list(recursive: true)) {
    if (entity is File && entity.path.toLowerCase().endsWith('.png')) {
      final fileName = entity.uri.pathSegments.last;
      final baseName = fileName.replaceAll('.png', '').toLowerCase();

      // Maak nette sleutel (zonder spaties of rare tekens)
      final key = baseName
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'(^-|-$)'), '');

      logos[key] = entity.path.replaceAll(r'\', '/');
    }
  }

  await outputFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(logos),
  );

  print('✅ Logos JSON gegenereerd!');
  print('📁 Bestand: ${outputFile.path}');
  print('📦 Aantal logos: ${logos.length}');
}
