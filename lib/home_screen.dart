import 'package:flutter/material.dart';
import 'package:mijn_iptv_app/m3u_provider.dart';
import 'package:mijn_iptv_app/models/m3u_entry.dart';
import 'package:mijn_iptv_app/player_screen.dart';

class HomeScreen extends StatefulWidget {
  final String m3uUrl;

  const HomeScreen({Key? key, required this.m3uUrl}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<M3UEntry> _channels = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    try {
      final data = await M3UProvider.loadM3U(widget.m3uUrl);
      setState(() {
        _channels = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('VibePlay+'),
        backgroundColor: Colors.red.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChannels,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : _channels.isEmpty
                  ? const Center(
                      child: Text(
                        "Geen kanalen gevonden 😢",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _channels.length,
                      itemBuilder: (context, index) {
                        final ch = _channels[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(
                                  channelName: ch.title,
                                  streamUrl: ch.streamUrl, // ✅ FIXED
                                  logoUrl: ch.logoUrl,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (ch.logoUrl != null &&
                                    ch.logoUrl!.isNotEmpty)
                                  Image.network(
                                    ch.logoUrl!,
                                    height: 60,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.tv,
                                            color: Colors.grey, size: 40),
                                  )
                                else
                                  const Icon(Icons.tv,
                                      color: Colors.grey, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  ch.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
