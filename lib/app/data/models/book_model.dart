class BookModel {
  int id;
  String title;
  String author;
  String coverUrl;
  String downloadUrl;
  String path;

  BookModel(
      {required this.id,
      required this.title,
      required this.author,
      required this.coverUrl,
      required this.downloadUrl,
      this.path = ""});

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
        id: map['id'] ?? 0,
        title: map['title'] ?? '',
        author: map['author'] ?? '',
        coverUrl: map['cover_url'] ?? '',
        downloadUrl: map['download_url'] ?? '');
  }
}
