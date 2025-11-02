// Dummy-implementatie voor web (geen Chromecast beschikbaar)
class CastDiscoveryService {
  Future<void> start() async {}
  Future<void> stop() async {}
  List get foundDevices => [];
}

class CastSession {
  Future<void> load(String url) async {}
}

class CastSessionManager {
  Stream<String> get stateStream => const Stream.empty();
}
