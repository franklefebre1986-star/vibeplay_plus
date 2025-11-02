import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class M3UInputScreen extends StatefulWidget {
  const M3UInputScreen({Key? key}) : super(key: key);

  @override
  State<M3UInputScreen> createState() => _M3UInputScreenState();
}

class _M3UInputScreenState extends State<M3UInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  /// 🔁 Laadt opgeslagen M3U-link uit shared_preferences
  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('m3u_url');
    if (saved != null && saved.isNotEmpty) {
      _controller.text = saved;
    } else {
      // standaard Nero-link
      _controller.text =
          'http://line.nero-ott.link/get.php?username=9835245497&password=7905352147&type=m3u_plus&output=m3u8';
    }
  }

  /// 💾 Sla link op en ga naar HomeScreen
  Future<void> _proceed() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;

    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('m3u_url', url);

    // 🧭 Navigeer naar HomeScreen met de M3U-link
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(m3uUrl: url)),
    );

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("VibePlay+ - M3U invoer"),
        backgroundColor: Colors.red.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Voer je M3U-link in",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Plak hier je M3U URL...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.red.shade900.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade700),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loading ? null : _proceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "LADEN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
