// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dishes.dart';
import 'restaurants.dart';
// import 'restaurantPage.dart';
import 'pinnedItems.dart';
import 'appColors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      theme: ThemeData(
          primaryColor: AppColors.primary,
          accentColor: AppColors.accent,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: HomePage(),
    );
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
  var pins = {
    'ids': <String>{},
    'items': [],
  };
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var zipCode = '';
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
          child: Container(
              padding: EdgeInsets.only(bottom: height / 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Find meatless meals near you",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.normal,
                          fontSize: height / 20)),
                  Container(
                      padding: EdgeInsets.only(top: height / 35),
                      height: height / 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: height / 10,
                              width: height / 3,
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                    decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.darkGrey,
                                              width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors.medGrey,
                                              width: 1.0),
                                        ),
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
                              )),
                        ],
                      )),
                  Container(
                      padding: EdgeInsets.only(top: height / 25),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: AppColors.primary,
                              minimumSize: Size(height / 8, height / 17)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              debugPrint(zipCode);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Mainpage(
                                        zipCode: zipCode, pins: widget.pins)),
                              );
                            }
                          },
                          child: Text('Search')))
                ],
              ))),
    );
  }
}

class Mainpage extends StatefulWidget {
  var zipCode;
  var pins;

  Mainpage({this.zipCode, this.pins});
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  var _displayRestaurants = true;
  var formVal;

  final _formKey = GlobalKey<FormState>();

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
                                      hintText: '${widget.zipCode}'),
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
                                      formVal = value;
                                    }
                                  }),
                            ))),
                    ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            setState(() {
                              debugPrint('setting zipCode $formVal');
                              widget.zipCode = formVal;

                              // _displayRestaurants = !_displayRestaurants;
                            });
                          }
                        },
                        child: Text('Search'))
                  ],
                )),
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
