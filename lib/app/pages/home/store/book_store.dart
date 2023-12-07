import 'package:epub_kitty_example/app/data/http/exceptions/not_found_exception.dart';
import 'package:epub_kitty_example/app/data/models/book_model.dart';
import 'package:epub_kitty_example/app/data/repositories/book_repository.dart';
import 'package:flutter/material.dart';

class BookStore {
  final IBookRepository _repository;

  BookStore({required IBookRepository repository}) : _repository = repository;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final ValueNotifier<List<BookModel>> state = ValueNotifier([]);

  final ValueNotifier<String> err = ValueNotifier("");

  Future getBooks() async {
    isLoading.value = true;

    try {
      final result = await _repository.getBooks();
      state.value = result;
    } on NotFoundException catch (e) {
      err.value = e.message;
    } catch (e) {
      err.value = e.toString();
    }

    isLoading.value = false;
  }
}
