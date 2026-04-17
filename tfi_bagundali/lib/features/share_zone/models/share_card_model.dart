class ShareCardModel {
  const ShareCardModel({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.thumbnailUrl,
    required this.shareCount,
    required this.isPremium,
  });

  final String id;
  final String title;
  final String category;
  final String emoji;
  final String? thumbnailUrl;
  final int shareCount;
  final bool isPremium;

  factory ShareCardModel.fromJson(Map<String, dynamic> json) {
    return ShareCardModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? 'All').toString(),
      emoji: (json['emoji'] ?? '📲').toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      shareCount: int.tryParse(json['share_count']?.toString() ?? '') ?? 0,
      isPremium: json['is_premium'] == true,
    );
  }
}
