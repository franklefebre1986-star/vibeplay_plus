// Dummy Chromecast classes voor Web — voorkomt build errors
class CastDiscoveryService {
  Future<void> search() async {}
  List get foundDevices => [];
}

class CastDevice {
  String get name => "Web-device";
  Future<CastSession> connect() async => CastSession();
}

class CastSession {
  Future<void> load(String url) async {}
}
