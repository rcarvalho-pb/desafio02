import 'dart:convert';

import 'package:epub_kitty_example/app/data/http/http_client.dart';
import 'package:epub_kitty_example/app/data/models/book_model.dart';
import 'package:epub_kitty_example/app/data/repositories/book_repository.dart';

import '../../http/exceptions/not_found_exception.dart';

class BookRepository implements IBookRepository {
  final url = "https://escribo.com/books.json";
  final IHttpClient _client;
  BookRepository({required IHttpClient client}) : _client = client;
  @override
  Future<List<BookModel>> getBooks() async {
    final response = await _client.get(url: url);
    if (response.statusCode == 200) {
      final List<BookModel> books = [];

      final body = jsonDecode(response.body);
      body.map((item) {
        final BookModel book = BookModel.fromMap(item);
        books.add(book);
      }).toList();
      return books;
    } else if (response.statusCode == 404) {
      throw NotFoundException("Url Inválida.");
    } else {
      throw Exception("Não foi possível carregar os livros.");
    }
  }

  @override
  Future<String> getBook() async {
    return "ola";
  }
}
