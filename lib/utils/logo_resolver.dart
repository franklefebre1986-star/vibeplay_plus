// lib/utils/logo_resolver.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;

class LogoResolver {
  // interne cache
  static Map<String, String>? _logosMap;
  static Future<void>? _loadingFuture;

  // éénmalig laden van assets/logos.json
  static Future<void> _ensureLoaded() {
    if (_loadingFuture != null) return _loadingFuture!;
    _loadingFuture = rootBundle.loadString('assets/logos.json').then((s) {
      final jsonData = jsonDecode(s) as Map<String, dynamic>;
      // lowercase keys voor makkelijk zoeken
      _logosMap = jsonData.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
    }).catchError((e) {
      // als het niet laadt, zorg dat _logosMap in ieder geval bestaat
      _logosMap = {};
      debugPrint('LogoResolver: kon logos.json niet laden: $e');
    });
    return _loadingFuture!;
  }

  // normalisatie van kanaalnaam
  static String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ') // rare tekens weg
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('hd', '')
        .replaceAll('tv', '')
        .trim();
  }

  // Bouw URL voor remote logo — pas aan als je eigen host hebt
  static String _onlineLogoUrlForKey(String key) {
    // veel logos.json entries zijn al paden. Maar we proberen een slimme fallback:
    // - als mapping niet gevonden, dan probeer key als bestandsnaam in tv-logos repo (remote).
    // Hier maken we geen harde assumptions — plugin/logo_generator heeft meestal asset paths.
    // Als je een remote-base wilt gebruiken, zet 'https://raw.githubusercontent.com/...' etc.
    return 'https://raw.githubusercontent.com/porath/TV-logos/main/assets/logos/${Uri.encodeComponent(key)}.png';
  }

  /// Publieke widget: gebruik in plaats van Image.asset direct.
  /// title = kanaalnaam uit M3U; country optioneel (kan weglaten)
  static Widget widget(String title, {String? country, double size = 50}) {
    return FutureBuilder<void>(
      future: _ensureLoaded(),
      builder: (context, snap) {
        // nog niet klaar? toon placeholder
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(
            width: size,
            height: size,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final norm = _normalize(title);
        // 1) directe key-match in logos.json
        final direct = _logosMap?[norm];
        if (direct != null && direct.isNotEmpty) {
          // direct is een asset pad zoals "tv-logos-main/countries/netherlands/rtl-nl.png"
          final assetPath = 'assets/logos/$direct';
          return Image.asset(assetPath, width: size, height: size, fit: BoxFit.contain, errorBuilder: (c, e, st) {
            // fallback: probeer network proxy
            return _networkFallbackWidget(norm, size);
          });
        }

        // 2) partiële match (zoek keys die contained zijn)
        for (final k in _logosMap!.keys) {
          if (norm.contains(k) || k.contains(norm)) {
            final candidate = _logosMap![k]!;
            final assetPath = 'assets/logos/$candidate';
            return Image.asset(assetPath, width: size, height: size, fit: BoxFit.contain, errorBuilder: (c, e, st) {
              return _networkFallbackWidget(norm, size);
            });
          }
        }

        // 3) niks gevonden: probeer direct network (kan door browser geblokkeerd zijn)
        return _networkFallbackWidget(norm, size);
      },
    );
  }

  // Probeer netwerk + proxied fallback
  static Widget _networkFallbackWidget(String normTitle, double size) {
    final url = _onlineLogoUrlForKey(normTitle);
    // eerste poging: directe NetworkImage
    final netImg = NetworkImage(url);

    // Gebruik Image with errorBuilder: als network faalt -> proxied via images.weserv.nl
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (ctx, err, st) {
        // proxied URL (images.weserv.nl)
        final proxied = 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}';
        return Image.network(
          proxied,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (c2, e2, s2) {
            // ultimate fallback: icon
            return Icon(Icons.tv, color: Colors.white54, size: size);
          },
        );
      },
    );
  }
}
