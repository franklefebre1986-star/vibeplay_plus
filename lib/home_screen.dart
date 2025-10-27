import 'package:flutter/material.dart';
import 'm3u_provider.dart' as net;
import 'file_m3u_provider.dart' as local;
import 'player_screen.dart';
import 'models/m3u_entry.dart';
import 'utils/logo_resolver.dart';

class HomeScreen extends StatefulWidget {
  final String? m3uUrl;
  const HomeScreen({super.key, this.m3uUrl});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  List<M3UEntry> _channels = [];

  Future<void> _loadFromInternet() async {
    if (widget.m3uUrl == null) return;
    setState(() => _loading = true);
    final channels = await net.M3UProvider.loadM3U(widget.m3uUrl!);
    setState(() {
      _channels = channels;
      _loading = false;
    });
  }

  Future<void> _loadFromFile() async {
    setState(() => _loading = true);
    final channels = await local.FileM3UProvider.pickAndParse();
    setState(() {
      _channels = channels;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.m3uUrl != null) {
      _loadFromInternet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "VibePlay+",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFromInternet,
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, color: Colors.white),
            tooltip: "Laad lokaal M3U-bestand",
            onPressed: _loadFromFile,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : _channels.isEmpty
              ? const Center(
                  child: Text(
                    "Geen kanalen gevonden 😢",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _channels.length,
                  itemBuilder: (context, i) {
                    final ch = _channels[i];

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(
                            streamUrl: ch.streamUrl,
                            title: ch.title,
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FutureBuilder<Widget>(
                                future: LogoResolver.buildLogo(
                                  ch.title,
                                  country: ch.country,
                                  size: 60,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return snapshot.data!;
                                  }
                                  return const Icon(
                                    Icons.tv,
                                    color: Colors.white54,
                                    size: 50,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                ch.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
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
