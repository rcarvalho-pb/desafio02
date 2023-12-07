import 'package:epub_kitty_example/app/data/models/book_model.dart';

abstract class IBookRepository {
  Future<List<BookModel>> getBooks();
  Future<String> getBook();
}
