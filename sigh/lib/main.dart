import 'dart:convert';
import 'dart:html';

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

// class Star extends StatefulWidget {
//   @override
//   _StarState createState() => _StarState()
// }

// class StarState extends State<Star> {
//   final bool pinned = false;
// }

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

  Widget restaurantDesc(name, type, friendliness) {
    final _iconSize = const TextStyle(fontSize: 30);

    return new ListTile(
      leading: Text('${friendliness}', style: _iconSize),
      title: Text(name),
      subtitle: Text(type),

      // trailing: Star(pinned: alreadyPinned)
    );
  }

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
                      child: restaurantDesc(
                          snapshot.data![position]["name"],
                          snapshot.data![position]["type"],
                          snapshot.data![position]["friendliness"]
                              .roundToDouble()));
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
