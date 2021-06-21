import 'dart:convert';
// import 'dart:html';

import 'package:flutter/material.dart';
// import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Test App', home: Mainpage());
  }
}

// class Star extends StatefulWidget {
//   @override
//   _StarState createState() => _StarState()
// }

// class StarState extends State<Star> {
//   final bool pinned = false;
// }

// stuff for dishes

class Mainpage extends StatefulWidget {
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  var _displayRestaurants = true;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _displayRestaurants ? Text('Restaurants') : Text('Dishes'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  child: Text('restaurants'),
                  onPressed: () {
                    setState(() {
                      _displayRestaurants = true;
                    });
                  },
                ),
                ElevatedButton(
                  child: Text('dishes'),
                  onPressed: () {
                    setState(() {
                      _displayRestaurants = false;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: _displayRestaurants ? Restaurants() : Dishes(),
            )
          ],
        ));
  }
}

class Dishes extends StatefulWidget {
  _DishesState createState() => _DishesState();
}

Future<List> getDishes() async {
  debugPrint('getting dishes');
  final response =
      await http.get(Uri.parse('http://localhost:4000/get-dishes'));

  debugPrint('${jsonDecode(response.body)['dishes'][0]}');
  // if (response.body.length > 100) {
  // debugPrint(jsonDecode(response.body));
  return jsonDecode(response.body)['dishes'];
  // }
}

class _DishesState extends State<Dishes> {
  late Future<List> _dishes;
  void initState() {
    super.initState();
    debugPrint('debug printing');
    _dishes = getDishes();
    debugPrint('$_dishes');
  }

  Widget dishDesc(name, description, image) {
    // var descriptionExists;
    // if (description == 'nu')
    return new ListTile(
      // leading: Text('${friendliness}', style: _iconSize),
      title: Text(name),
      subtitle: description == 'none' ? null : Text(description),
      // trailing: Icon(Icons.star)
      // Star(pinned: alreadyPinned)
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      SizedBox(
          height: MediaQuery.of(context).size.height - 84,
          child: Center(
              child: FutureBuilder<List>(
            future: _dishes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, int position) {
                    return Card(
                        child: dishDesc(
                            snapshot.data![position]["name"],
                            snapshot.data![position]["description"],
                            snapshot.data![position]["images"]));
                  },
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return SizedBox(
                child: CircularProgressIndicator(),
                height: 50.0,
                width: 50.0,
              );
            },
          )))
    ]));
  }
}

// stuff for restaurants

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
      // trailing: Icon(Icons.star)
      // Star(pinned: alreadyPinned)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height - (84),
        child: Center(
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
            return SizedBox(
              child: CircularProgressIndicator(),
              height: 50.0,
              width: 50.0,
            );
          },
        )),
      )
    ]));
  }
}
