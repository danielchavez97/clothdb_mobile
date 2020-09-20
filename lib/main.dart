import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> results = new List();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    fetch(1);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        int page = results.length ~/ 10 + 1;
        fetch(page);

        // do something to wait for 2 seconds
        await Future.delayed(const Duration(seconds: 3), () {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("ClothDB"),
      ),
      backgroundColor: Colors.white,
      body: GridView.builder(
          controller: _scrollController,
          itemCount: results.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Image.network(
                      'https://d2x1mfjcaooqwx.cloudfront.net/' +
                          results[index]['thumbnails'][0],
                      height: 175,
                      width: 200,
                      fit: BoxFit.fitWidth,
                    ),
                    color: Colors.white,
                  ),
                  Container(
                    child: ListTile(
                      title: Text(results[index]['brand']),
                      subtitle: Text(results[index]['name']),
                    ),
                  ),
                ],
              ),
            );
          }),
    ));
  }

  fetch(int i) async {
    final response =
        await http.get('https://clothdb.com/api/LoadItems?page=$i');
    if (response.statusCode == 200) {
      setState(() {
        results += json.decode(response.body)['results'];
      });
    } else {
      throw Exception('failed to load');
    }
  }
}
