class NewsArticle {
  final int id;
  final String title;
  final String content;
  final String category;
  final String author;
  final DateTime publishedDate;
  final String imageUrl;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.publishedDate,
    required this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: int.parse(json['news_id'].toString()),
      title: json['headline_title'] ?? '',
      content: json['content_body'] ?? '',
      category: json['category_tag'] ?? '',
      author: json['author_source'] ?? '',
      publishedDate: DateTime.parse(json['date_time_published']),
      imageUrl: json['image_url'] ?? '',
    );
  }
}