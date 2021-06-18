import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Test App', home: Restaurants());
  }
}

class Restaurants extends StatefulWidget {
  final String name = '';

  @override
  _RestaurantsState createState() => _RestaurantsState();
}

Future<List> getRestaurants() async {
  debugPrint('getting restaurants');
  final response =
      await http.get(Uri.parse('http://localhost:4000/get-restaurants'));

  debugPrint('${jsonDecode(response.body)['restaurants'][0]}');
  // if (response.body.length > 100) {
  // debugPrint(jsonDecode(response.body));
  return jsonDecode(response.body)['restaurants'];
  // }
}

class _RestaurantsState extends State<Restaurants> {
  late Future<List> _restaurants;
  // final _biggerFont = const TextStyle(fontSize: 18);

  void initState() {
    super.initState();
    debugPrint('debug printing');
    _restaurants = getRestaurants();
    debugPrint('$_restaurants');
  }

  // Widget _buildRow(WordPair pair) {
  //   return ListTile(
  //     title: Text(
  //       pair.asPascalCase,
  //       style: _biggerFont,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Test App'),
        ),
        body: Center(
            child: FutureBuilder<List>(
          future: _restaurants,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, int position) {
                  return Card(
                    child: ListTile(
                      title: Text(snapshot.data![position]["name"]),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        )));
  }
}
