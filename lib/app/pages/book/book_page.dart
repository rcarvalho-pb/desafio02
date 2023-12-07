import 'dart:io';

import 'package:dio/dio.dart';
import 'package:epub_kitty_example/app/data/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

class BookPage extends StatefulWidget {
  BookModel book;
  BookPage({required this.book});
  @override
  State<StatefulWidget> createState() => _BookPage();
}

class _BookPage extends State<BookPage> {
  final platform = MethodChannel('my_channel');
  bool loading = false;
  Dio dio = Dio();
  String filePath = "";

  void initState() {
    existBook(widget.book);
    super.initState();
  }

  /// ANDROID VERSION
  fetchAndroidVersion(BookModel book) async {
    final String? version = await getAndroidVersion();
    if (version != null) {
      String? firstPart;
      if (version.toString().contains(".")) {
        int indexOfFirstDot = version.indexOf(".");
        firstPart = version.substring(0, indexOfFirstDot);
      } else {
        firstPart = version;
      }
      int intValue = int.parse(firstPart);
      if (intValue >= 13) {
        await startDownload(book);
      } else {
        final PermissionStatus status = await Permission.storage.request();
        if (status == PermissionStatus.granted) {
          await startDownload(book);
        } else {
          await Permission.storage.request();
        }
      }
      print("ANDROID VERSION: $intValue");
      return "";
    }
  }

  Future<String?> getAndroidVersion() async {
    try {
      final String version = await platform.invokeMethod('getAndroidVersion');
      return version;
    } on PlatformException catch (e) {
      print("FAILED TO GET ANDROID VERSION: ${e.message}");
      return null;
    }
  }

  existBook(BookModel book) async {
    setState(() {
      loading = true;
    });
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir!.path + '/${book.title}.epub';

    if (File(path).existsSync()) {
      book.path = path;
    }
  }

  download(BookModel book) async {
    if (Platform.isIOS) {
      final PermissionStatus status = await Permission.storage.request();
      if (status == PermissionStatus.granted) {
        return await startDownload(book);
      } else {
        await Permission.storage.request();
      }
    } else if (Platform.isAndroid) {
      await fetchAndroidVersion(book);
    } else {
      PlatformException(code: '500');
    }
  }

  startDownload(BookModel book) async {
    setState(() {
      loading = true;
    });
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir!.path + '/${book.title}.epub';
    File file = File(path);

    if (!file.existsSync()) {
      await file.create();
      await dio.download(
        book.downloadUrl,
        path,
        deleteOnError: true,
        onReceiveProgress: (receivedBytes, totalBytes) {
          print('Download --- ${(receivedBytes / totalBytes) * 100}');
          setState(() {
            loading = true;
          });
        },
      ).whenComplete(() {
        setState(() {
          loading = false;
          book.path = path;
        });
      });
    } else {
      setState(() {
        loading = false;
        book.path = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.book;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.book.title),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.network(item.coverUrl),
            ElevatedButton(
                child: Text(
                    '${item.path.isNotEmpty ? "Read Book" : "Download Book"}'),
                onPressed: () async {
                  print(item.path.isNotEmpty);
                  print("=====filePath======${item.path}");
                  if (item.path.isEmpty) {
                    download(item);
                  } else {
                    VocsyEpub.setConfig(
                      themeColor: Theme.of(context).primaryColor,
                      identifier: "iosBook",
                      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
                      allowSharing: true,
                      enableTts: true,
                      nightMode: true,
                    );
                    // get current locator
                    VocsyEpub.locatorStream.listen((locator) {
                      print('LOCATOR: $locator');
                    });
                    print("FilePath ok, open vocsy");
                    VocsyEpub.open(
                      item.path,
                      lastLocation: EpubLocator.fromJson({
                        "bookId": "2239",
                        "href": "/OEBPS/ch06.xhtml",
                        "created": 1539934158390,
                        "locations": {
                          "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
                        }
                      }),
                    );
                  }
                }),
          ]),
        ));
  }
}
