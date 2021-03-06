// import 'package:flutter/foundation.dart';

import 'dart:convert';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:sigh/restaurantPage.dart';

import 'dishes.dart';
import 'restaurants.dart';
// import 'restaurantPage.dart';
import 'pinnedItems.dart';
import 'appColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        // Handle '/restaurant/:id'
        var name = settings.name.toString();
        var uri = Uri.parse(name);
        debugPrint(
            '${uri.pathSegments}, ${uri.pathSegments.length}, ${uri.pathSegments.first}');
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments.first == 'restaurant') {
          var args = settings.arguments as Map;

          var info = args['info'];
          var pins = args['pins'];
          debugPrint('args, $args');
          return MaterialPageRoute(
              builder: (context) => RestaurantPage(info: info, pins: pins),
              settings: settings);
        }
      },
      title: 'Meatless',
      theme: ThemeData(
          primaryColor: Colors.white,
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
  const HomePage();

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var pins;

  getPins() async {
    var pins;
    await SharedPreferences.getInstance().then((prefs) {
      pins =
          prefs.getString('pins') ?? jsonEncode({'items': [], 'display': true});
    });
    pins = jsonDecode(pins);
    return pins;
  }

  void initState() {
    super.initState();
    getPins().then((value) => {
          debugPrint('$value, value'),
          setState(() {
            pins = value;
          })
        });
  }

  var zipCode = '';
  final _formKey = GlobalKey<FormState>();
  final zipCodeController = TextEditingController();

  Widget build(BuildContext context) {
    if (pins == null) {
      setState(() {
        pins = {'items': [], 'display': true};
      });
    }
    debugPrint('$pins, build');
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
                                        contentPadding: EdgeInsets.only(
                                            bottom: 1, left: 10),
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
                                    },
                                    onFieldSubmitted: (value) {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();

                                        debugPrint(zipCode);
                                        zipCodeController.clear();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => Mainpage(
                                                    zipCode: zipCode,
                                                  )),
                                        );
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
                                          zipCode: zipCode,
                                        )),
                              );
                            }
                          },
                          child: const Text('Search')))
                ],
              ))),
    );
  }
}

class Mainpage extends StatefulWidget {
  Mainpage({this.zipCode});
  var zipCode;

  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  var zipCode, pins;

  var _displayRestaurants = true;
  var formVal;
  refresh() {
    setState(() {});
  }

  Future getPins() async {
    var pins;
    await SharedPreferences.getInstance().then((prefs) {
      pins =
          prefs.getString('pins') ?? jsonEncode({'items': [], 'display': true});
    });
    pins = jsonDecode(pins);
    return pins;
  }

  Future<void> savePins(pins) async {
    final temp = jsonEncode(pins);
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('pins', temp);
    });
  }

  void initState() {
    super.initState();
    getPins().then((value) => {
          debugPrint('$value, value'),
          setState(() {
            pins = value;
          })
        });
  }

  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    if (pins == null) {
      setState(() {
        pins = {'items': [], 'display': true};
      });
    }
    zipCode = widget.zipCode;

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
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
              padding: EdgeInsets.only(bottom: height / 150, top: height / 150),
              child: width < 500
                  ? Text("M",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: height / 30))
                  : Text('MEATLESS',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: height / 50))),
          actions: [
            Container(
                padding: width < 500
                    ? EdgeInsets.only(bottom: height / 150, top: height / 150)
                    : EdgeInsets.only(bottom: height / 100, top: height / 100),
                height: height / 12,
                width: height / 6,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 1, left: 15),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                                color: AppColors.darkGrey, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                                color: AppColors.medGrey, width: 1.5),
                          ),
                          hintText: '$zipCode'),
                      onSaved: (value) {
                        if (value is String) {
                          formVal = value;
                        }
                      },
                      onFieldSubmitted: (value) {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          setState(() {
                            debugPrint('setting zipCode $formVal');
                            widget.zipCode = formVal;

                            // _displayRestaurants = !_displayRestaurants;
                          });
                        }
                      }),
                )),
            Container(
              padding: width < 500
                  ? EdgeInsets.only(bottom: height / 150, top: height / 150)
                  : EdgeInsets.only(
                      bottom: height / 100,
                      top: height / 100,
                      right: height / 30),
              height: MediaQuery.of(context).size.height / 10,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      side: BorderSide(
                          width: 2,
                          color: width < 500
                              ? AppColors.medGrey
                              : AppColors.primaryDark),
                      shape: const RoundedRectangleBorder(
                        borderRadius: const BorderRadius.only(
                            topRight: const Radius.circular(12),
                            bottomRight: const Radius.circular(12)),
                      ),
                      // padding: EdgeInsets.only(bottom: height / 90),
                      primary: width < 500 ? Colors.white : AppColors.primary,
                      minimumSize: Size(height / 40, height / 30)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      setState(() {
                        debugPrint('setting zipCode $formVal');
                        zipCode = formVal;
                      });
                    }
                  },
                  child: Icon(Icons.search,
                      color: width < 500 ? AppColors.darkGrey : null)),
            ),
            Container(
                padding: EdgeInsets.only(
                    bottom: height / 150,
                    top: height / 150,
                    right: height / 50),
                child: InkWell(
                    onTap: () {
                      var toSet = !pins['display'];
                      setState(() {
                        pins['display'] = toSet;
                        savePins(pins);
                      });
                      if (width < 1000) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PinnedItems(
                                    pins: pins,
                                    notifyMain: refresh,
                                  )),
                        ).then((val) => setState(() {}));
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                            height: 60,
                            width: 50,
                            child: Icon(Icons.star,
                                color: pins["items"].length > 0
                                    ? AppColors.accent
                                    : AppColors.medGrey,
                                size: 30),
                            alignment: Alignment.center),
                        if (pins['items'].length > 0)
                          Container(
                              // decoration: BoxDecoration(
                              //     shape: BoxShape.circle, color: Colors.black),
                              height: 60,
                              width: 50,
                              child: Text('${pins['items'].length}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              alignment: Alignment.center)
                      ],
                    )))
          ],
        ),
        body: Row(
          children: [
            Expanded(
                flex: 31,
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.only(top: height / 70, left: height / 70),
                      child: Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                side: BorderSide(
                                    width: 1, color: AppColors.medGrey),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: const Radius.circular(7),
                                      bottomLeft: const Radius.circular(7)),
                                ),
                                // padding: EdgeInsets.only(bottom: height / 90),
                                primary: Colors.white,
                                minimumSize: Size(height / 15, height / 20)),
                            child: Text('Restaurants',
                                style: TextStyle(
                                    color: _displayRestaurants
                                        ? AppColors.darkText
                                        : AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
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
                                side: BorderSide(
                                    width: 1, color: AppColors.medGrey),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(7),
                                      bottomRight: Radius.circular(7)),
                                ),
                                primary: Colors.white,
                                minimumSize: Size(height / 15, height / 20)),
                            child: Text('Dishes',
                                style: TextStyle(
                                    color: _displayRestaurants
                                        ? AppColors.primaryDark
                                        : AppColors.darkText,
                                    fontWeight: FontWeight.w600,
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

                    // TODO: refactor restaurants and dishes to collapse reusable components
                    Expanded(
                      child: _displayRestaurants
                          ? Restaurants(
                              pins: pins,
                              zipCode: zipCode,
                              notifyParent: refresh,
                            )
                          : Dishes(
                              zipCode: zipCode,
                              notifyParent: refresh,
                            ),
                    )
                  ],
                )),
            if (pins['display'] && width > 1000)
              VerticalDivider(width: 1, color: AppColors.medGrey),
            if (pins['display'] && width > 1000)
              Expanded(
                  flex: 9,
                  child: PinnedItems(
                    pins: pins,
                    notifyMain: refresh,
                  ))
          ],
        ));
  }
}
