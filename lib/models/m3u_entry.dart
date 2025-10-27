class M3UEntry {
  final String title;
  final String streamUrl;
  final String? logoUrl;
  final String? country;

  M3UEntry({
    required this.title,
    required this.streamUrl,
    this.logoUrl,
    this.country,
  });
}
