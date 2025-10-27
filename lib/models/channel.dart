class Channel {
  final String name;
  final String url;
  final String? logo;      // tvg-logo from playlist (may be null)
  final String group;      // category/group-title
  final String? epgId;     // tvg-id if present

  Channel({
    required this.name,
    required this.url,
    this.logo,
    required this.group,
    this.epgId,
  });
}
