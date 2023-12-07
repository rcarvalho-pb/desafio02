import 'package:epub_kitty_example/app/data/http/implementations/http_client_impl.dart';
import 'package:epub_kitty_example/app/data/repositories/implementations/book_repository_impl.dart';
import 'package:epub_kitty_example/app/pages/book/book_page.dart';
import 'package:epub_kitty_example/app/pages/home/store/book_store.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BookStore store = BookStore(
    repository: BookRepository(
      client: HttpClient(),
    ),
  );

  @override
  void initState() {
    super.initState();
    store.getBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'e-Reader - Desafio 2',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([store.isLoading, store.err, store.state]),
        builder: (context, child) {
          if (store.isLoading.value == true) {
            return const CircularProgressIndicator();
          }

          if (store.err.value.isNotEmpty) {
            return Center(
              child: Text(
                store.err.value,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (store.state.value.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum Livro na lista",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.42,
              ),
              itemCount: store.state.value.length,
              itemBuilder: (context, index) {
                final item = store.state.value[index];
                const bookmark = Icons.bookmark_outline;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return BookPage(
                                    book: item,
                                  );
                                },
                              ),
                            );
                          },
                          child: Image.network(item.coverUrl),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(
                              bookmark,
                              color: Colors.yellow,
                              size: 50,
                            ),
                            onPressed: () {
                              print("oi");
                            },
                          ),
                        ),
                      ],
                    ),
                    ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.author),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
