class MarketItem {
  final int id;
  final String createdAt;
  final String name;
  final String minecraftTag;
  final String avatarUrl;

  MarketItem({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.minecraftTag,
    required this.avatarUrl,
  });

  factory MarketItem.fromMap(Map<String, dynamic> map) {
    return MarketItem(
      id: map['id'],
      createdAt: map['created_at'],
      name: map['name'],
      minecraftTag: map['minecraft_tag'],
      avatarUrl: map['avatar_url'],
    );
  }
}
