import 'dart:convert';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dishes.dart';
import 'restaurants.dart';
// import 'restaurantPage.dart';
import 'pinnedItems.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Test App', home: HomePage());
  }
}

// class Star extends StatefulWidget {
//   @override
//   _StarState createState() => _StarState()
// }

// class StarState extends State<Star> {
//   final bool pinned = false;
// }

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var zipCode = '';
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Text("Find meatless meals near you",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height / 30)),
        Container(
            height: MediaQuery.of(context).size.height / 10,
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height / 10,
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                              decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  hintText: 'Enter 5-digit zip code'),
                              validator: (value) {
                                RegExp validate = RegExp(r'^[0-9]{5}$');
                                var isValid;
                                if (value is String) {
                                  var temp = validate.stringMatch(value);
                                  if (temp == null) {
                                    isValid = false;
                                  } else {
                                    isValid = true;
                                  }
                                }
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a zip code';
                                } else if (!isValid) {
                                  return 'Please enter a valid zip code';
                                }

                                // regex
                              },
                              onSaved: (value) {
                                if (value is String) {
                                  zipCode = value;
                                }
                              }),
                        ))),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        var body = zipCode;
                        debugPrint(zipCode);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => Mainpage(zipCode: zipCode)),
                        );
                      }
                    },
                    child: Text('Search'))
              ],
            ))
      ],
    ));
  }
}

class Mainpage extends StatefulWidget {
  var zipCode;
  var pins = {
    'ids': <String>{},
    'items': [],
  };

  Mainpage({this.zipCode});
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
                  ? Restaurants(pins: widget.pins, zipCode: widget.zipCode)
                  : Dishes(pins: widget.pins, zipCode: widget.zipCode),
            )
          ],
        ));
  }
}
