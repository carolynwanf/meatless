import 'dart:convert';
// import 'dart:html';

import 'package:flutter/foundation.dart';
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
  var pins = <String>{};
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  var _displayRestaurants = true;

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Meatless'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  child: Text('restaurants'),
                  onPressed: !_displayRestaurants
                      ? () {
                          setState(() {
                            _displayRestaurants = true;
                          });
                        }
                      : null,
                ),
                ElevatedButton(
                  child: Text('dishes'),
                  onPressed: _displayRestaurants
                      ? () {
                          setState(() {
                            _displayRestaurants = false;
                          });
                        }
                      : null,
                ),
              ],
            ),
            Expanded(
              child: _displayRestaurants
                  ? Restaurants(pins: widget.pins)
                  : Dishes(pins: widget.pins),
            )
          ],
        ));
  }
}

class Dishes extends StatefulWidget {
  var pins;

  Dishes({this.pins});
  _DishesState createState() => _DishesState();
}

Future<List> getDishes(offset) async {
  final String body = jsonEncode({"offset": offset});
  final response =
      await http.post(Uri.parse('http://localhost:4000/get-dishes'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body);

  // if (response.body.length > 100) {
  return jsonDecode(response.body)['dishes'];
  // }
}

// class PinnedItems extends

class _DishesState extends State<Dishes> {
  late Future<List> _dishes;
  var page = 1;

  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  void initState() {
    super.initState();
    _dishes = getDishes(page);
  }

  Widget dishDesc(name, description, image, price, restaurant, pinned, id) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (description.length > 80) {
      description = description.substring(0, 80);
      description = description + "...";
    }

    if (image != 'none') {
      image = image.split(" 1920w,");
      image = image[0];

      image = image.split(
          'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/');

      image = image[1];
    }
    // var descriptionExists;
    // if (description == 'nu')
    return Container(
        child: Column(children: [
      if (image != 'none')
        Container(
          height: width / 10,
          child: Image.network(image),
        ),
      Text(name,
          style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: height / 55),
          textAlign: TextAlign.center),
      if (description != 'none')
        Text(description,
            style: TextStyle(color: Colors.grey[800], fontSize: height / 60),
            textAlign: TextAlign.center),
      IconButton(
          onPressed: !pinned
              ? () {
                  debugPrint('pressed');
                  var temp = widget.pins;
                  debugPrint('$temp');
                  temp.add(id);

                  setState(() {
                    widget.pins = temp;
                  });
                }
              : () {
                  debugPrint('pressed');
                  var temp = widget.pins;
                  debugPrint('$temp');
                  temp.remove(id);

                  setState(() {
                    debugPrint('setting state');
                    widget.pins = temp;
                  });
                },
          icon: pinned ? Icon(Icons.star) : Icon(Icons.star_border))
    ]));

    // USE FOR MOBILE INTERFACE LATER ON
    // return new ListTile(
    //   leading: Container(
    //     child: Column(
    //       children: [
    //         if (image != 'none')
    //           Container(
    //             height: MediaQuery.of(context).size.height / 17,
    //             child: Image.network(image),
    //           )
    //       ],
    //     ),
    //   ),
    //   title: Text(name),
    //   subtitle: description == 'none' ? null : Text(description),
    //   // trailing: Icon(Icons.star)
    //   // Star(pinned: alreadyPinned)
    // );
  }

  Widget build(BuildContext context) {
    debugPrint('$page');
    isDisabled() {
      if (page == 1) {
        return true;
      } else {
        return false;
      }
    }

    calculateCount(size) {
      if (size.width < 480) {
        return 2;
      } else if (size.width < 767) {
        return 3;
      } else if (size.width < 991) {
        return 4;
      } else {
        return 5;
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
              }

              // labels items from snapshot as pinned/not based on state
              for (var i = 0; i < snapshot.data!.length; i++) {
                var item = snapshot.data![i]["_id"];

                if (widget.pins.contains(item)) {
                  snapshot.data![i]['pinned'] = true;
                } else {
                  snapshot.data![i]['pinned'] = false;
                }
              }
              return GridView.builder(
                itemCount: snapshot.data!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: calculateCount(MediaQuery.of(context).size),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: (1.3 / 1.5),
                ),
                itemBuilder: (_, int position) {
                  if (snapshot.data![position] != 'end') {
                    return Card(
                        child: dishDesc(
                            snapshot.data![position]["name"],
                            snapshot.data![position]["description"],
                            snapshot.data![position]["images"],
                            snapshot.data![position]["price"],
                            snapshot.data![position]['restuarant_name'],
                            snapshot.data![position]['pinned'],
                            snapshot.data![position]['_id']));
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
  var pins;
  Restaurants({this.pins});
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

  Widget restaurantDesc(name, type, friendliness, id) {
    final _iconSize = const TextStyle(fontSize: 30);

    var info = {'name': name, 'type': type, 'id': id};

    return new ListTile(
      leading: Text('${friendliness}', style: _iconSize),
      title: Text(name),
      subtitle: Text(type),
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RestaurantPage(info: info, pins: widget.pins)),
        )
      },
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
                                .roundToDouble(),
                            snapshot.data![position]["_id"]));
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

// stuff for restaurant page

class RestaurantPage extends StatefulWidget {
  var info;
  var pins;

  RestaurantPage({Key? key, @required this.info, this.pins}) : super(key: key);

  _RestaurantPageState createState() => _RestaurantPageState();
}

Future<List> getPageDishes(id) async {
  final String body = jsonEncode({"id": id});
  final response =
      await http.post(Uri.parse('http://localhost:4000/get-page-dishes'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body);

  return jsonDecode(response.body)['dishes'];
}

// stuff for restaurant page

class _RestaurantPageState extends State<RestaurantPage> {
  late Future<List> _dishes;

  void initState() {
    super.initState();
    _dishes = getPageDishes(widget.info['id']);

    // debugPrint('$_restaurants');
  }

  Widget itemDesc(name, description, image, price, restaurant, pinned, id) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (description.length > 80) {
      description = description.substring(0, 80);
      description = description + "...";
    }

    if (image != 'none') {
      image = image.split(" 1920w,");
      image = image[0];

      image = image.split(
          'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/');

      image = image[1];
    }
    // var descriptionExists;
    // if (description == 'nu')
    return Card(
        child: Column(children: [
      if (image != 'none')
        Container(
          height: width / 10,
          child: Image.network(image),
        ),
      Text(name,
          style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: height / 55),
          textAlign: TextAlign.center),
      if (description != 'none')
        Text(description,
            style: TextStyle(color: Colors.grey[800], fontSize: height / 60),
            textAlign: TextAlign.center),
      IconButton(
          onPressed: !pinned
              ? () {
                  debugPrint('pressed');
                  var temp = widget.pins;
                  debugPrint('$temp');
                  temp.add(id);

                  setState(() {
                    widget.pins = temp;
                  });
                }
              : () {
                  debugPrint('pressed');
                  var temp = widget.pins;
                  debugPrint('$temp');
                  temp.remove(id);

                  setState(() {
                    debugPrint('setting state');
                    widget.pins = temp;
                  });
                },
          icon: pinned ? Icon(Icons.star) : Icon(Icons.star_border))
    ]));
  }

  calculateCount(size) {
    if (size.width < 480) {
      return 2;
    } else if (size.width < 767) {
      return 3;
    } else if (size.width < 991) {
      return 4;
    } else {
      return 5;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: MediaQuery.of(context).size.height / 15,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(widget.info['name']),
          ),
        ),
        SliverToBoxAdapter(
            child: FutureBuilder<List>(
                future: _dishes,
                builder: (context, snapshot) {
                  debugPrint('$snapshot');
                  if (snapshot.hasData) {
                    for (var i = 0; i < snapshot.data!.length; i++) {
                      for (var j = 0; j < snapshot.data![i].length; j++) {
                        var item = snapshot.data![i][j]["_id"];

                        if (widget.pins.contains(item)) {
                          snapshot.data![i][j]['pinned'] = true;
                        } else {
                          snapshot.data![i][j]['pinned'] = false;
                        }
                      }
                    }
                    return Column(children: [
                      Text('Mains'),
                      Container(
                          height:
                              MediaQuery.of(context).size.height * (19 / 20),
                          child: GridView.builder(
                            itemCount: snapshot.data![0].length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  calculateCount(MediaQuery.of(context).size),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: (1.3 / 1.5),
                            ),
                            itemBuilder: (context, index) {
                              return itemDesc(
                                  snapshot.data![0][index]['name'],
                                  snapshot.data![0][index]['description'],
                                  snapshot.data![0][index]['images'],
                                  snapshot.data![0][index]['price'],
                                  snapshot.data![0][index]['restuarant_name'],
                                  snapshot.data![0][index]['pinned'],
                                  snapshot.data![0][index]['_id']);
                            },
                          )),
                      if (snapshot.data![1].length > 0) Text("Sides"),
                      if (snapshot.data![1].length > 0)
                        Container(
                            height:
                                MediaQuery.of(context).size.height * (19 / 20),
                            child: GridView.builder(
                              itemCount: snapshot.data![1].length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    calculateCount(MediaQuery.of(context).size),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: (1.3 / 1.5),
                              ),
                              itemBuilder: (context, index) {
                                return itemDesc(
                                    snapshot.data![1][index]['name'],
                                    snapshot.data![1][index]['description'],
                                    snapshot.data![1][index]['images'],
                                    snapshot.data![1][index]['price'],
                                    snapshot.data![1][index]['restuarant_name'],
                                    snapshot.data![0][index]['pinned'],
                                    snapshot.data![1][index]['_id']);
                              },
                            )),
                      if (snapshot.data![2].length > 0) Text("Desserts"),
                      if (snapshot.data![2].length > 0)
                        Container(
                            height:
                                MediaQuery.of(context).size.height * (19 / 20),
                            child: GridView.builder(
                              itemCount: snapshot.data![2].length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    calculateCount(MediaQuery.of(context).size),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: (1.3 / 1.5),
                              ),
                              itemBuilder: (context, index) {
                                return itemDesc(
                                    snapshot.data![2][index]['name'],
                                    snapshot.data![2][index]['description'],
                                    snapshot.data![2][index]['images'],
                                    snapshot.data![2][index]['price'],
                                    snapshot.data![2][index]['restuarant_name'],
                                    snapshot.data![0][index]['pinned'],
                                    snapshot.data![2][index]['_id']);
                              },
                            )),
                    ]);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  // By default, show a loading spinner.
                  return Center(
                    child: SizedBox(
                      child: CircularProgressIndicator(),
                      height: 50.0,
                      width: 50.0,
                    ),
                  );
                })),
      ],
    ));
  }
}
