// import 'dart:convert';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

import 'dishes.dart';
import 'restaurants.dart';
// import 'restaurantPage.dart';
import 'pinnedItems.dart';

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

class Mainpage extends StatefulWidget {
  var pins = {
    'ids': <String>{},
    'items': [],
  };
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  var _displayRestaurants = true;

  // getRequests(async) {
  //   ;
  // }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Meatless'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PinnedItems(pins: widget.pins)),
                  ).then((val) => setState(() {}));
                },
                icon: Icon(Icons.star))
          ],
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
