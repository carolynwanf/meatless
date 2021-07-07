// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dishes.dart';
import 'restaurants.dart';
// import 'restaurantPage.dart';
import 'pinnedItems.dart';
import 'appColors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  var pins = {
    'ids': <String>{},
    'items': [],
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: AppColors.accent,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: HomePage(pins: pins),
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
  var pins;

  HomePage({this.pins});

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var zipCode = '';
  final _formKey = GlobalKey<FormState>();
  final zipCodeController = TextEditingController();

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
                                    controller: zipCodeController,
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
                              zipCodeController.clear();

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
  refresh() {
    setState(() {});
  }

  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
              child: Container(
                color: AppColors.lightGrey,
                height: 1.0,
              ),
              preferredSize: Size.fromHeight(1.0)),
          elevation: 0,
          iconTheme: IconThemeData(
            color: AppColors.medGrey, //change your color here
          ),
          title: Container(
              padding: EdgeInsets.only(bottom: height / 150),
              child: width < 1000
                  ? Text("M",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: height / 30))
                  : Text('Meatless',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: height / 30))),
          actions: [
            Container(
                padding: EdgeInsets.only(bottom: height / 150),
                height: height / 12,
                width: height / 5,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                                color: AppColors.darkGrey, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.medGrey, width: 1.0),
                          ),
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
                )),
            Container(
              padding: EdgeInsets.only(bottom: height / 150),
              height: MediaQuery.of(context).size.height / 10,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(width: 2, color: AppColors.primaryDark),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                      ),
                      // padding: EdgeInsets.only(bottom: height / 90),
                      primary: AppColors.primary,
                      minimumSize: Size(height / 40, height / 30)),
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
                  child: Icon(Icons.search)),
            ),
            Container(
                padding: EdgeInsets.only(bottom: height / 150),
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PinnedItems(pins: widget.pins)),
                      ).then((val) => setState(() {}));
                    },
                    icon: Icon(Icons.star,
                        color: widget.pins["items"].length > 0
                            ? AppColors.primary
                            : AppColors.medGrey)))
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(height / 70),
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: BorderSide(width: 1, color: AppColors.medGrey),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(7),
                              bottomLeft: Radius.circular(7)),
                        ),
                        // padding: EdgeInsets.only(bottom: height / 90),
                        primary: AppColors.primary,
                        minimumSize: Size(height / 15, height / 20)),
                    child: Text('Restaurants',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: height / 45)),
                    onPressed: !_displayRestaurants
                        ? () {
                            setState(() {
                              _displayRestaurants = true;
                            });
                          }
                        : null,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: BorderSide(width: 1, color: AppColors.medGrey),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(7),
                              bottomRight: Radius.circular(7)),
                        ),
                        // padding: EdgeInsets.only(bottom: height / 90),
                        primary: AppColors.primary,
                        minimumSize: Size(height / 15, height / 20)),
                    child: Text('Dishes',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: height / 45)),
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
            ),
            Expanded(
              child: _displayRestaurants
                  ? Restaurants(
                      pins: widget.pins,
                      zipCode: widget.zipCode,
                      notifyParent: refresh,
                    )
                  : Dishes(pins: widget.pins, zipCode: widget.zipCode),
            )
          ],
        ));
  }
}
