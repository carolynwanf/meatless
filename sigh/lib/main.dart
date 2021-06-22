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

Future<List> getDishes(offset) async {
  debugPrint('getting dishes');
  final String body = jsonEncode({"offset": offset});
  final response =
      await http.post(Uri.parse('http://localhost:4000/get-dishes'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body);

  debugPrint('${jsonDecode(response.body)['dishes'][0]}');
  // if (response.body.length > 100) {
  // debugPrint(jsonDecode(response.body));
  return jsonDecode(response.body)['dishes'];
  // }
}

class _DishesState extends State<Dishes> {
  late Future<List> _dishes;
  var page = 1;

  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  void initState() {
    super.initState();
    debugPrint('debug printing');
    _dishes = getDishes(page);
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
    debugPrint('$page');
    isDisabled() {
      if (page == 1) {
        debugPrint('disabled $page');
        return true;
      } else {
        return false;
      }
    }

    return Scaffold(
        body: Column(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height - (138),
        child: Center(
            child: FutureBuilder<List>(
          future: _dishes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length < 8) {
                snapshot.data!.add('end');
                debugPrint('${snapshot.data}');
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, int position) {
                  if (snapshot.data![position] != 'end') {
                    return Card(
                        child: dishDesc(
                            snapshot.data![position]["name"],
                            snapshot.data![position]["description"],
                            snapshot.data![position]["images"]));
                  } else {
                    return Text('End of results');
                  }
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
      ),
      Row(
        children: [
          ElevatedButton(
              onPressed: isDisabled()
                  ? null
                  : () => {
                        setState(() {
                          page = page - 1;
                          _dishes = getDishes(page);
                        })
                      },
              child: Text('Prev')),
          Container(
              child: TextField(
                controller: fieldText,
                onSubmitted: (value) {
                  debugPrint('debugging $value');
                  var number = int.tryParse(value);
                  if (number != null && 0 < number && number < 3937) {
                    setState(() {
                      page = number;
                      _dishes = getDishes(number);
                    });

                    clearText();
                  }
                },
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), hintText: 'page #'),
              ),
              width: 50),
          FutureBuilder<List>(
            future: _dishes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ElevatedButton(
                    onPressed: snapshot.data!.length < 7
                        ? null
                        : () => {
                              setState(() {
                                page = page + 1;
                                _dishes = getDishes(page);
                              })
                            },
                    child: Text('Next'));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return Text('');
              }
            },
          ),
        ],
      )
    ]));
  }
}

// stuff for restaurants

class Restaurants extends StatefulWidget {
  @override
  _RestaurantsState createState() => _RestaurantsState();
}

Future<List> getRestaurants(offset) async {
  debugPrint('getting restaurants');

  final String body = jsonEncode({"offset": offset});
  final response =
      await http.post(Uri.parse('http://localhost:4000/get-restaurants'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body);

  // debugPrint('response');
  // debugPrint('${jsonDecode(response.body)['restaurants'][0]}');

  return jsonDecode(response.body)['restaurants'];
}

class _RestaurantsState extends State<Restaurants> {
  late Future<List> _restaurants;
  var page = 1;
  // final _biggerFont = const TextStyle(fontSize: 18);

  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  void initState() {
    super.initState();
    debugPrint('debug printing');
    _restaurants = getRestaurants(page);

    // debugPrint('$_restaurants');
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
    debugPrint('$page');
    isDisabled() {
      if (page == 1) {
        debugPrint('disabled $page');
        return true;
      } else {
        return false;
      }
    }

    return Scaffold(
        body: Column(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height - (138),
        child: Center(
            child: FutureBuilder<List>(
          future: _restaurants,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              while (snapshot.data![snapshot.data!.length - 1]
                          ["friendliness"] ==
                      null &&
                  snapshot.data![snapshot.data!.length - 2]["friendliness"] ==
                      null) {
                snapshot.data!.removeAt(snapshot.data!.length - 1);
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, int position) {
                  if (snapshot.data![position]["friendliness"] == null) {
                    return Text('End of results');
                  } else {
                    return Card(
                        child: restaurantDesc(
                            snapshot.data![position]["name"],
                            snapshot.data![position]["type"],
                            snapshot.data![position]["friendliness"]
                                .roundToDouble()));
                  }
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
      ),
      Row(
        children: [
          ElevatedButton(
              onPressed: isDisabled()
                  ? null
                  : () => {
                        setState(() {
                          page = page - 1;
                          _restaurants = getRestaurants(page);
                        })
                      },
              child: Text('Prev')),
          Container(
              child: TextField(
                controller: fieldText,
                onSubmitted: (value) {
                  var number = int.tryParse(value);
                  if (number != null && 0 < number && number < 118) {
                    setState(() {
                      page = number;
                      _restaurants = getRestaurants(number);
                    });

                    clearText();
                  }
                },
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), hintText: 'page #'),
              ),
              width: 50),
          FutureBuilder<List>(
            future: _restaurants,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ElevatedButton(
                    onPressed: snapshot.data![7]['friendliness'] == null
                        ? null
                        : () => {
                              setState(() {
                                page = page + 1;
                                _restaurants = getRestaurants(page);
                              })
                            },
                    child: Text('Next'));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return Text('');
              }
            },
          ),
        ],
      )
    ]));
  }
}
