class AdminMessage {
  final int id;
  final String title;
  final String content;
  final DateTime date;
  final String authorName;
  final bool important;

  AdminMessage({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.authorName,
    this.important = false,
  });

  factory AdminMessage.fromMap(Map<String, dynamic> map) {
    return AdminMessage(
      id:
          map['id'] is int
              ? map['id'] as int
              : int.tryParse(map['id'].toString()) ?? 0,
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      date: DateTime.parse(
        map['date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      authorName:
          map['author_name']?.toString() ?? map['authorName']?.toString() ?? '',
      important:
          map['important'] is bool
              ? map['important'] as bool
              : (map['important']?.toString().toLowerCase() == 'true'),
    );
  }
}
