import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'itemDialog.dart';
import 'appColors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dishes extends StatefulWidget {
  Dishes({
    this.zipCode,
    this.notifyParent,
  });

  final zipCode, notifyParent;
  _DishesState createState() => _DishesState();
}

Future<List> getDishes(offset, zipCode, search, query) async {
  final String body = jsonEncode(
      {"offset": offset, 'zipCode': zipCode, 'search': search, 'query': query});
  final response =

      // for local android dev
      // await http.post(Uri.parse('http://10.0.2.2:4000/get-dishes'),
      //     headers: {
      //       'Accept': 'application/json',
      //       'Content-Type': 'application/json',
      //     },
      //     body: body);

      // for local ios + browser dev
      await http.post(Uri.parse('http://localhost:4000/get-dishes'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body);

  return jsonDecode(response.body)['dishes'];
}

class _DishesState extends State<Dishes> {
  var starToast;

  var pins;

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

  @override
  void initState() {
    super.initState();
    starToast = FToast();
    starToast.init(context);

    getPins().then((value) => {
          debugPrint('$value, value'),
          setState(() {
            pins = value;
          })
        });
  }

  _showToast(text) {
    var color = AppColors.accent;
    if (text == 'Unstarred') {
      color = Colors.black;
    }

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (text == 'Starred') Icon(Icons.star, color: Colors.white),
          if (text == "Unstarred") Icon(Icons.cancel, color: Colors.white),
          SizedBox(
            width: 12.0,
          ),
          Text("$text",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );

    starToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(milliseconds: 1500),
    );
  }

  var search = false, query = '', zipCode;
  final ScrollController _scrollController = ScrollController();
  var page = 1;

  final _formKey = GlobalKey<FormState>();
  var formVal;

  final fieldText = TextEditingController();
  final searchResultsController = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  Widget dishDesc(item, currentPins) {
    var name = item['name'],
        description = item['description'],
        image = item['images'],
        price = item['price'],
        pinned = item['pinned'],
        restaurant = item['restuarant_name'],
        id = item['_id'];
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    if (description.length > 55) {
      description = description.substring(0, 55);
      description = description + "...";
    }
    if (name.length > 50) {
      name = name.substring(0, 50);
      name = name + "...";
    }

    if (image != 'none') {
      image = image.split(" 1920w,");
      image = image[0];

      image = image.split(
          'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/');

      image = image[1];
    }

    void showItemDesc() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ItemDialog(
              pins: currentPins,
              item: item,
            );
          }).then((val) => {setState(() {}), widget.notifyParent()});
    }

    void addPin() {
      var temp = currentPins;

      temp['items'].add(item);
      debugPrint('$temp');

      setState(() {
        pins = temp;
        savePins(temp);
      });
      if (width < 500) {
        _showToast("Starred");
      }

      widget.notifyParent();
    }

    void removePin() {
      var temp = currentPins;
      debugPrint('$temp');

      for (var i = 0; i < temp['items'].length; i++) {
        if (temp['items'][i]['_id'] == id) {
          temp['items'].removeAt(i);
          break;
        }
      }
      setState(() {
        debugPrint('setting state');
        pins = temp;
        savePins(temp);
      });

      if (width < 500) {
        _showToast("Unstarred");
      }
      widget.notifyParent();
    }

    Widget star() {
      return InkWell(
          onTap: !pinned
              ? () {
                  addPin();
                }
              : () {
                  removePin();
                },
          hoverColor: AppColors.noHover,
          child: Container(
              height: 30,
              width: 30,
              child: Stack(
                children: [
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      alignment: Alignment.center),
                  Container(
                      height: 30,
                      width: 30,
                      child: pinned
                          ? Icon(Icons.star, color: AppColors.star)
                          : Icon(Icons.star_border, color: AppColors.medGrey),
                      alignment: Alignment.center),
                ],
              )));
    }

    if (width < 500) {
      // mobile dish card
      return Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: InkWell(
              hoverColor: AppColors.noHover,
              onTap: showItemDesc,
              onDoubleTap: !pinned
                  ? () {
                      addPin();
                    }
                  : () {
                      removePin();
                    },
              child: Column(children: [
                Container(
                    padding: EdgeInsets.only(top: 5, bottom: 15),
                    // contents of card
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // text
                        Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Column(children: [
                              // dish name
                              Container(
                                width: width / 2 - 10,
                                child: Text(
                                  name,
                                  style: AppStyles.headerMobile,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              // dish description if it exists
                              if (description != 'none')
                                Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    width: width / 2 - 10,
                                    child: Text(
                                      description,
                                      textAlign: TextAlign.left,
                                      style: AppStyles.subtitleMobile,
                                    )),
                              // dish price and restaurant
                              Container(
                                  width: width / 2 - 10,
                                  child: Text('$price ??? $restaurant',
                                      textAlign: TextAlign.left,
                                      style: AppStyles.detailMobile))
                            ])),
                        // image if it exists
                        if (image != 'none')
                          Container(
                              height: height / 6,
                              width: width / 2 - 15,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Image.network(
                                          image,
                                          alignment: Alignment.topCenter,
                                          fit: BoxFit.cover,
                                          width: height / 4,
                                          height: height / 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 10, right: 5, child: star()),
                                ],
                              )),
                        // placeholder image if image does not exist
                        if (image == 'none')
                          Container(
                              decoration: BoxDecoration(
                                  color: AppColors.medGrey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              height: height / 6 - 5,
                              width: width / 2 - 15,
                              child: Stack(
                                children: [
                                  Center(
                                      child: Text('no image',
                                          style:
                                              TextStyle(color: Colors.white))),
                                  Positioned(
                                      bottom: 10, right: 5, child: star())
                                ],
                              ))
                      ],
                    )),
                // divider
                Container(
                    width: width - 10, height: 1, color: AppColors.lightGrey)
              ])));
    } else {
      return InkWell(
          hoverColor: AppColors.noHover,
          onTap: showItemDesc,
          child: Container(
              height: 300,
              padding: EdgeInsets.only(
                  left: width / 200,
                  right: width / 200,
                  top: width / 200,
                  bottom: width / 200),
              child: Stack(children: [
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  //image
                  if (image != 'none')
                    Container(
                      padding: EdgeInsets.only(
                        bottom: width / 100,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Image.network(
                              image,
                              alignment: Alignment.topCenter,
                              fit: BoxFit.cover,
                              width: double.maxFinite,
                              height: height / 6,
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (image == 'none')
                    Container(
                        padding: EdgeInsets.fromLTRB(3, 3, 3, width / 100),
                        child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.medGrey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            height: height / 6,
                            width: double.maxFinite,
                            child: Center(
                                child: Text('no image',
                                    style: TextStyle(color: Colors.white))))),
                  Container(
                      padding: EdgeInsets.only(
                        bottom: width / 400,
                      ),
                      child: Text(name,
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: height / 55),
                          textAlign: TextAlign.center)),
                  if (description != 'none')
                    Text(description,
                        style: AppStyles.subtitle, textAlign: TextAlign.center),
                  Text(
                    '$price ??? $restaurant',
                    textAlign: TextAlign.center,
                    style: AppStyles.detail,
                  ),
                ]),
                Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                        onTap: !pinned
                            ? () {
                                addPin();
                              }
                            : () {
                                removePin();
                              },
                        hoverColor: AppColors.noHover,
                        child: Container(
                            height: 30,
                            width: 30,
                            child: Stack(
                              children: [
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    alignment: Alignment.center),
                                Container(
                                    height: 30,
                                    width: 30,
                                    child: pinned
                                        ? Icon(Icons.star,
                                            color: AppColors.star)
                                        : Icon(Icons.star_border,
                                            color: AppColors.medGrey),
                                    alignment: Alignment.center),
                              ],
                            ))))
              ])));
    }
  }

  Widget build(BuildContext context) {
    var zipCode = widget.zipCode;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var mobile = width > 500 ? false : true;
    debugPrint('$page');
    isDisabled() {
      if (page == 1) {
        return true;
      } else {
        return false;
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          Container(
            padding: mobile
                ? EdgeInsets.only(left: height / 50)
                : EdgeInsets.only(
                    left: height / 50, top: height / 50, bottom: 15),

            // search bar
            child: Row(
              children: [
                // search bar form
                Container(
                    padding:
                        EdgeInsets.only(bottom: height / 80, top: height / 100),
                    height: mobile ? height / 16 : height / 17,
                    width: mobile ? width / 3 : width / 5,
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: searchResultsController,
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding:
                                EdgeInsets.only(bottom: 1, left: 10),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                              ),
                              borderSide: BorderSide(
                                  color: AppColors.darkGrey, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5),
                              ),
                              borderSide: BorderSide(
                                  color: AppColors.medGrey, width: 1),
                            ),
                            hintStyle: const TextStyle(fontSize: 12),
                            hintText: search ? '$query' : 'search'),
                        onSaved: (value) {
                          if (value is String) {
                            formVal = value;
                          }
                        },
                        onFieldSubmitted: (value) {
                          _formKey.currentState!.save();
                          if (formVal == null ||
                              formVal.isEmpty ||
                              formVal == ' ' ||
                              formVal == '') {
                            setState(() {
                              search = false;
                              page = 1;

                              // _displayRestaurants = !_displayRestaurants;
                            });
                          } else {
                            setState(() {
                              search = true;
                              query = formVal;
                              page = 1;

                              // _displayRestaurants = !_displayRestaurants;
                            });
                          }
                        },
                      ),
                    )),

                // search bar button
                Container(
                    padding:
                        EdgeInsets.only(bottom: height / 80, top: height / 100),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            side: BorderSide(
                                width: mobile ? 1 : 2,
                                color: AppColors.medGrey),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  bottomRight: Radius.circular(7)),
                            ),
                            // padding: EdgeInsets.only(bottom: height / 90),
                            primary: Colors.white,
                            minimumSize: mobile
                                ? Size(height / 40, height / 25)
                                : Size(height / 40, height / 21.5)),
                        onPressed: search
                            ? () {
                                searchResultsController.clear();
                                setState(() {
                                  search = false;
                                  query = '';
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
                                    search = false;
                                    page = 1;

                                    // _displayRestaurants = !_displayRestaurants;
                                  });
                                } else {
                                  setState(() {
                                    search = true;
                                    query = formVal;
                                    page = 1;

                                    // _displayRestaurants = !_displayRestaurants;
                                  });
                                }
                              },
                        child: search
                            ? Icon(Icons.cancel,
                                size: 17, color: AppColors.darkGrey)
                            : Icon(Icons.search,
                                size: 17, color: AppColors.darkGrey)))
              ],
            ),
          ),

          // divider
          if (mobile) Container(height: 1, color: AppColors.medGrey),
          // dishes
          Container(
            height: mobile ? height * (3 / 5) : (height) * (13 / 20),
            color: mobile ? null : AppColors.lightestGrey,
            child: Center(
                child: FutureBuilder<List>(
              future: getDishes(page, zipCode, search, query),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data![0] == 'no results') {
                    return Text('no results');
                  } else {
                    // labels items from snapshot as pinned/not based on state
                    for (var i = 0; i < snapshot.data!.length; i++) {
                      var itemId = snapshot.data![i]["_id"];
                      var pinnedIds = <String>{};

                      for (var j = 0; j < pins['items'].length; j++) {
                        pinnedIds.add(pins['items'][j]['_id']);
                      }
                      if (pinnedIds.contains(itemId)) {
                        snapshot.data![i]['pinned'] = true;
                      } else {
                        snapshot.data![i]['pinned'] = false;
                      }
                    }
                    if (!mobile) {
                      return Padding(
                          padding: EdgeInsets.all(10),
                          child: GridView.builder(
                            itemCount: snapshot.data!.length,
                            controller: _scrollController,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250,
                              mainAxisExtent: 300,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: (1.3 / 1.8),
                            ),
                            itemBuilder: (_, int position) {
                              return Card(
                                  child:
                                      dishDesc(snapshot.data![position], pins));
                            },
                          ));
                    } else {
                      return ListView.builder(
                          controller: _scrollController,
                          itemCount: snapshot.data!.length,
                          shrinkWrap: true,
                          itemBuilder: (_, int position) {
                            return dishDesc(snapshot.data![position], pins);
                          });
                    }
                  }
                } else if (snapshot.hasError) {
                  return Text("Server down, try again later");
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
          if (mobile) Container(height: 1, color: AppColors.medGrey),
          // choose your page
          Container(
              padding: EdgeInsets.only(top: height / 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // prev page button
                  if (!isDisabled())
                    IconButton(
                        hoverColor: AppColors.noHover,
                        onPressed: () async {
                          setState(() {
                            page = page - 1;
                          });
                          await Future.delayed(
                              const Duration(milliseconds: 300));

                          SchedulerBinding.instance
                              ?.addPostFrameCallback((timeStamp) {
                            _scrollController.animateTo(
                                _scrollController.position.minScrollExtent,
                                duration: const Duration(milliseconds: 10),
                                curve: Curves.fastOutSlowIn);
                          });
                        },
                        icon: Icon(Icons.arrow_back_ios,
                            size: 20, color: AppColors.darkGrey)),
                  // field for entering custom page number
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
                            contentPadding:
                                EdgeInsets.only(bottom: 1, left: 10),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.medGrey, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.lightGrey, width: 1),
                            ),
                            hintText: '$page',
                            hintStyle: TextStyle(fontSize: 12)),
                      )),
                  // next page button
                  FutureBuilder<List>(
                    future: getDishes(page, zipCode, search, query),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
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
                              hoverColor: AppColors.noHover,
                              onPressed: () async {
                                setState(() {
                                  page = page + 1;
                                });

                                await Future.delayed(
                                    const Duration(milliseconds: 300));

                                SchedulerBinding.instance
                                    ?.addPostFrameCallback((timeStamp) {
                                  _scrollController.animateTo(
                                      _scrollController
                                          .position.minScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 10),
                                      curve: Curves.fastOutSlowIn);
                                });
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
