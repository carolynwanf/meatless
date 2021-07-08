import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sigh/appColors.dart';
import 'restaurantPage.dart';
import 'appColors.dart';

class Restaurants extends StatefulWidget {
  var notifyParent;
  var pins;
  var zipCode;
  var sort = 'friendliness';
  var search = false;
  var query = '';

  Restaurants({this.pins, this.zipCode, this.notifyParent});
  @override
  _RestaurantsState createState() => _RestaurantsState();
}

Future<List> getRestaurants(offset, zipCode, sort, search, query) async {
  debugPrint('getting restaurants, $zipCode, $sort, $search');

  final String body = jsonEncode({
    "offset": offset,
    'zipCode': zipCode,
    'sort': sort,
    "search": search,
    "query": query
  });
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
  var page = 1;
  final _formKey = GlobalKey<FormState>();
  var formVal;

  // final _biggerFont = const TextStyle(fontSize: 18);

  final fieldText = TextEditingController();
  final searchResultsController = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  Widget restaurantDesc(name, type, friendliness, id, mains) {
    var height = MediaQuery.of(context).size.height;
    final _iconSize = const TextStyle(fontSize: 30);
    var info = {'name': name, 'id': id};

    if (MediaQuery.of(context).size.width < 500) {
      return new ListTile(
        leading: Text('$friendliness', style: _iconSize),
        title: Text(name),
        subtitle: Text(type),
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => RestaurantPage(info: info, pins: widget.pins)),
          ).then((val) => {setState(() {}), widget.notifyParent()})
        },
        // trailing: Icon(Icons.star)
        // Star(pinned: alreadyPinned)
      );
    } else {
      return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      RestaurantPage(info: info, pins: widget.pins)),
            ).then((val) => {setState(() {}), widget.notifyParent()});
          },
          child: Container(
              padding: EdgeInsets.all(height / 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$friendliness', style: _iconSize),
                  Text(
                    name,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: height / 55),
                    textAlign: TextAlign.center,
                  ),
                  if (name != type) Text(type, textAlign: TextAlign.center),
                ],
              )));

      // new ListTile(
      //   leading: Text('$friendliness', style: _iconSize),
      //   title: Text(name),
      //   subtitle: Text(type),
      //   onTap: () => {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //           builder: (_) => RestaurantPage(info: info, pins: widget.pins)),
      //     ).then((val) => {setState(() {}), widget.notifyParent()})
      //   },
      //   // trailing: Icon(Icons.star)
      //   // Star(pinned: alreadyPinned)
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var zipCode = widget.zipCode;
    debugPrint('$page');
    isDisabled() {
      if (page == 1) {
        return true;
      } else {
        return false;
      }
    }

    calculateCount(size) {
      if (size.width < 550) {
        return 2;
      } else if (size.width < 767) {
        return 3;
      } else if (size.width < 950) {
        return 4;
      } else if (size.width < 1200) {
        return 5;
      } else {
        return 6;
      }
    }

    return Scaffold(
        body: Column(children: [
      Container(
          height: MediaQuery.of(context).size.height / 10,
          child: Row(
            children: [
              Row(
                children: [
                  Container(
                      padding: EdgeInsets.only(
                          left: height / 40, right: height / 100),
                      child: Text("Sort by:")),
                  Container(
                      padding: EdgeInsets.only(right: height / 40),
                      child: DropdownButton(
                        value: widget.sort,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 20,
                        elevation: 16,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            debugPrint('changed $value');
                            widget.sort = value!;
                            page = 1;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                              value: 'friendliness',
                              child: Text('friendliness')),
                          DropdownMenuItem<String>(
                              value: '# of meatless dishes',
                              child: Text('meatless dishes'))
                        ],
                      ))
                ],
              ),
              Container(
                  padding:
                      EdgeInsets.only(bottom: height / 80, top: height / 100),
                  height: MediaQuery.of(context).size.height / 15,
                  width: MediaQuery.of(context).size.width / 7,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                        controller: searchResultsController,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                              borderSide: BorderSide(
                                  color: AppColors.medGrey, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                              borderSide: BorderSide(
                                  color: AppColors.lightGrey, width: 1),
                            ),
                            hintStyle: TextStyle(fontSize: 13),
                            hintText:
                                widget.search ? '${widget.query}' : 'search'),
                        onSaved: (value) {
                          if (value is String) {
                            formVal = value;
                          }
                        }),
                  )),
              Container(
                  padding:
                      EdgeInsets.only(bottom: height / 80, top: height / 100),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: BorderSide(
                              width: 2, color: AppColors.primaryDark),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                          ),
                          // padding: EdgeInsets.only(bottom: height / 90),
                          primary: AppColors.primary,
                          minimumSize: Size(height / 40, height / 18.5)),
                      onPressed: widget.search
                          ? () {
                              searchResultsController.clear();
                              setState(() {
                                widget.search = false;
                                widget.query = '';
                                page = 1;

                                // _displayRestaurants = !_displayRestaurants;
                              });
                            }
                          : () {
                              _formKey.currentState!.save();
                              if (formVal == null ||
                                  formVal.isEmpty ||
                                  formVal == ' ' ||
                                  formVal == '') {
                                setState(() {
                                  widget.search = false;
                                  page = 1;

                                  // _displayRestaurants = !_displayRestaurants;
                                });
                              } else {
                                setState(() {
                                  widget.search = true;
                                  widget.query = formVal;
                                  page = 1;

                                  // _displayRestaurants = !_displayRestaurants;
                                });
                              }
                            },
                      child: widget.search
                          ? Text("x", style: TextStyle(fontSize: 24))
                          : Icon(Icons.search, size: 24)))
            ],
          )),
      Container(
        height: (MediaQuery.of(context).size.height) * (3 / 5),
        padding: EdgeInsets.fromLTRB(height / 50, 0, height / 50, 0),
        child: Center(
            child: FutureBuilder<List>(
          future: getRestaurants(
              page, zipCode, widget.sort, widget.search, widget.query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              debugPrint('${snapshot.data}');
              if (snapshot.data![0] == 'no results') {
                return Text('no results');
              } else {
                if (snapshot.data!.length < 8 &&
                    snapshot.data![snapshot.data!.length - 1]["end"] != true) {
                  const end = {"end": true};
                  snapshot.data!.add(end);
                }

                if (width < 500) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, int position) {
                      if (snapshot.data![position]["end"] == true) {
                        return Text('End of results');
                      } else {
                        debugPrint(
                            'type ${snapshot.data![position]["friendliness"]}');
                        if (snapshot.data![position]["friendliness"] != null &&
                            snapshot.data![position]["friendliness"] != 'N/A') {
                          snapshot.data![position]["friendliness"] =
                              snapshot.data![position]["friendliness"].round();
                        } else {
                          snapshot.data![position]["friendliness"] = "N/A";
                        }
                        return restaurantDesc(
                            snapshot.data![position]["name"],
                            snapshot.data![position]["type"],
                            snapshot.data![position]["friendliness"],
                            snapshot.data![position]["_id"],
                            snapshot.data![position]["totalVegItems"]);
                      }
                    },
                  );
                } else {
                  return GridView.builder(
                    itemCount: snapshot.data!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          calculateCount(MediaQuery.of(context).size),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: (1.3 / 1.5),
                    ),
                    itemBuilder: (_, int position) {
                      if (snapshot.data![position]["end"] == true) {
                        return Text('End of results');
                      } else {
                        debugPrint(
                            'type ${snapshot.data![position]["friendliness"]}');
                        if (snapshot.data![position]["friendliness"] != null &&
                            snapshot.data![position]["friendliness"] != 'N/A') {
                          snapshot.data![position]["friendliness"] =
                              snapshot.data![position]["friendliness"].round();
                        } else {
                          snapshot.data![position]["friendliness"] = "N/A";
                        }
                        return Card(
                            child: restaurantDesc(
                                snapshot.data![position]["name"],
                                snapshot.data![position]["type"],
                                snapshot.data![position]["friendliness"],
                                snapshot.data![position]["_id"],
                                snapshot.data![position]["totalVegItems"]));
                      }
                    },
                  );
                }
              }
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return SizedBox(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
              height: 50.0,
              width: 50.0,
            );
          },
        )),
      ),
      Container(
          padding: EdgeInsets.only(top: height / 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isDisabled())
                IconButton(
                    hoverColor: Colors.white.withOpacity(0),
                    onPressed: () => {
                          setState(() {
                            page = page - 1;
                          })
                        },
                    icon: Icon(Icons.arrow_back_ios,
                        size: 20, color: AppColors.darkGrey)),
              Container(
                  width: height / 15,
                  height: height / 25,
                  child: TextField(
                    controller: fieldText,
                    onSubmitted: (value) {
                      var number = int.tryParse(value);
                      if (number != null && 0 < number && number < 118) {
                        setState(() {
                          page = number;
                        });

                        clearText();
                      }
                    },
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.medGrey, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.lightGrey, width: 1),
                        ),
                        hintText: '$page',
                        hintStyle: TextStyle(fontSize: 13)),
                  )),
              FutureBuilder<List>(
                future: getRestaurants(
                    page, zipCode, widget.sort, widget.search, widget.query),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    debugPrint(
                        'AHH ${snapshot.data!.length}, ${snapshot.data![snapshot.data!.length - 1]}');
                    var end = true;
                    if (snapshot.data![0] != 'no results') {
                      if (snapshot.data!.length == 15) {
                        end = false;
                      }
                    }

                    if (end) {
                      return Text('');
                    } else {
                      return IconButton(
                          hoverColor: Colors.white.withOpacity(0),
                          onPressed: () => {
                                setState(() {
                                  page = page + 1;
                                })
                              },
                          icon: Icon(Icons.arrow_forward_ios,
                              size: 20, color: AppColors.darkGrey));
                    }
                  } else {
                    return Text('');
                  }
                },
              ),
            ],
          ))
    ]));
  }
}
