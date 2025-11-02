import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:cast/cast.dart' if (dart.library.html) 'cast_stub.dart';

class PlayerScreen extends StatefulWidget {
  final String channelName;
  final String streamUrl;
  final String? logoUrl;

  const PlayerScreen({
    Key? key,
    required this.channelName,
    required this.streamUrl,
    this.logoUrl,
  }) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  CastDiscoveryService? _discovery;
  CastDevice? _device;
  CastSession? _session;

  bool _error = false;
  String _streamType = "";

  @override
  void initState() {
    super.initState();
    _initPlayer();
    if (!kIsWeb) _initCast();
  }

  Future<void> _initPlayer() async {
    final testedUrl = await _checkStream(widget.streamUrl);
    if (testedUrl == null) {
      setState(() => _error = true);
      return;
    }

    // bepaal type voor overlay
    setState(() {
      _streamType = testedUrl.contains('.m3u8') ? 'HLS' : 'TS';
    });

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(testedUrl))
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
    } catch (e) {
      debugPrint('❌ Video fout: $e');
      setState(() => _error = true);
    }
  }

  /// 🧠 Controleer of stream werkt, anders probeer fallback
  Future<String?> _checkStream(String url) async {
    try {
      final res = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return url;
    } catch (_) {}

    // fallback: probeer m3u8 of ts variant
    if (url.contains('.ts')) {
      final alt = url.replaceAll('.ts', '.m3u8');
      try {
        final res = await http.head(Uri.parse(alt)).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) return alt;
      } catch (_) {}
    } else if (url.contains('.m3u8')) {
      final alt = url.replaceAll('.m3u8', '.ts');
      try {
        final res = await http.head(Uri.parse(alt)).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) return alt;
      } catch (_) {}
    }
    return null;
  }

  Future<void> _initCast() async {
    try {
      _discovery = CastDiscoveryService();
      await _discovery!.search();
      debugPrint("🔎 Chromecast zoeken gestart...");
    } catch (e) {
      debugPrint("❌ Cast discovery fout: $e");
    }
  }

  Future<void> _castToFirstDevice() async {
    if (_discovery == null) return;
    final devices = _discovery!.foundDevices;

    if (devices.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Geen Chromecast gevonden")));
      return;
    }

    final device = devices.first;
    _session = await device.connect();
    await _session!.load(widget.streamUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Afspelen op ${device.name}")),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _controller?.value.isInitialized ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
        backgroundColor: Colors.red.shade800,
        actions: [
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.cast),
              onPressed: _castToFirstDevice,
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: _error
            ? const Text(
                "❌ Stream niet beschikbaar",
                style: TextStyle(color: Colors.red, fontSize: 16),
              )
            : ready
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_controller!),

                        // 📺 Logo rechtsboven
                        if (widget.logoUrl != null)
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Image.network(widget.logoUrl!, height: 40),
                          ),

                        // 🧠 Debug overlay rechtsboven (stream type)
                        if (_streamType.isNotEmpty)
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _streamType == 'HLS'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              child: Text(
                                _streamType == 'HLS'
                                    ? '🎥 HLS'
                                    : '🎞 TS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(color: Colors.red),
      ),
      floatingActionButton: ready
          ? FloatingActionButton(
              backgroundColor: Colors.red.shade700,
              onPressed: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
              child: Icon(
                _controller!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
