class APOD {
  final String title;
  final String explanation;
  final String url;
  final String? date;

  const APOD({
    required this.title,
    required this.explanation,
    required this.url,
    this.date,
  });

  factory APOD.fromJson(Map<String, dynamic> json) {
    return APOD(
      title: json['title'] ?? 'Sin título',
      explanation: json['explanation'] ?? 'Sin descripción',
      url: json['hurl'] ?? json['url'] ?? '',
      date: json['date'],
    );
  }
}
