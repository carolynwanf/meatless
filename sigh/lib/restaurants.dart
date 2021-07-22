import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:sigh/appColors.dart';
import 'restaurantPage.dart';
import 'appColors.dart';
import 'package:pie_chart/pie_chart.dart';

class RestaurantCard extends StatefulWidget {
  final notifyMain;
  final pins;
  final restaurant;
  final pinsOnDisplay;

  RestaurantCard({
    @required this.pins,
    @required this.notifyMain,
    @required this.restaurant,
    @required this.pinsOnDisplay,
  });

  _RestaurantCardState createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  Widget build(BuildContext context) {
    var restaurant = widget.restaurant;

    var name = restaurant['name'],
        type = restaurant['type'],
        friendliness = restaurant['friendliness'],
        id = restaurant['_id'],
        mains = restaurant['totalVegItems'];
    // var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var info = {
      'name': name,
      'id': id,
    };
    var unfriendliness = 100 - friendliness;

    if (type.length > 30) {
      type = type.substring(0, 30);
      type = type + "...";
    }
    Map<String, double> dataMap = {
      "veggie": friendliness.toDouble(),
      "notVeggie": unfriendliness.toDouble(),
    };
    Widget friendlinessChart() {
      return PieChart(
        dataMap: dataMap,
        chartLegendSpacing: 32,
        chartRadius: 50,
        colorList: [AppColors.primary, Color(0xFFEC873B)],
        initialAngleInDegree: 270,
        chartType: ChartType.ring,
        ringStrokeWidth: 25,
        legendOptions: LegendOptions(
          showLegends: false,
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValues: false,
        ),
      );
    }

    if (width < 500) {
      // restaurant tile
      return InkWell(
          onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RestaurantPage(
                            info: info,
                            pins: widget.pins,
                            pinsOnDisplay: widget.pinsOnDisplay,
                          )),
                ).then((val) => {widget.notifyMain()})
              },
          // restaurant information
          child: Column(
            children: [
              Container(
                  // height: height / 6,
                  padding: EdgeInsets.only(bottom: 10, top: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // restaurant name + type
                        Expanded(
                            flex: 3,
                            child: Column(children: [
                              // restaurant name
                              Container(
                                  width: width * (7 / 12),
                                  child: Text(name,
                                      style: AppStyles.headerMobile,
                                      textAlign: TextAlign.left)),
                              //restaurant type
                              Container(
                                  width: width * (7 / 12),
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(type,
                                      style: AppStyles.subtitleMobile,
                                      textAlign: TextAlign.left)),
                              // friendliness
                              Container(
                                  padding: EdgeInsets.only(bottom: 5),
                                  width: width * (7 / 12),
                                  child: Text(
                                    '$mains mains',
                                    textAlign: TextAlign.left,
                                    style: AppStyles.detailMobile,
                                  )),
                              Container(
                                  width: width * (7 / 12),
                                  child: Text('$friendliness',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary)))

                              // kinds of items
                            ])),
                        // friendliness chart
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: friendlinessChart()))
                      ])),
              Container(
                  width: width - 10, height: 1, color: AppColors.lightGrey)
            ],
          ));
    } else {
      return Card(
          child: InkWell(
              hoverColor: AppColors.noHover,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RestaurantPage(
                            info: info,
                            pins: widget.pins,
                            pinsOnDisplay: widget.pinsOnDisplay,
                          )),
                ).then((val) => {widget.notifyMain()});
              },
              child: Container(
                  height: 250,
                  width: 200,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, width / 70),
                          child: friendlinessChart()),
                      Text(
                        name,
                        style: AppStyles.header,
                        textAlign: TextAlign.center,
                      ),
                      if (name != type)
                        Text(type,
                            style: AppStyles.subtitle,
                            textAlign: TextAlign.center),
                      Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text('$mains mains',
                              textAlign: TextAlign.left,
                              style: AppStyles.detail)),
                      Container(
                          child: Text('$friendliness',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)))
                    ],
                  ))));
    }
  }
}

class Restaurants extends StatefulWidget {
  final notifyParent;
  final pins;
  final zipCode;
  final pinsOnDisplay;

  Restaurants(
      {this.pins,
      this.zipCode,
      this.notifyParent,
      @required this.pinsOnDisplay});
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

      // for local android dev
      // await http.post(Uri.parse('http://10.0.2.2:4000/get-restaurants'),
      //     headers: {
      //       'Accept': 'application/json',
      //       'Content-Type': 'application/json',
      //     },
      //     body: body);

      // for local ios + browser dev
      await http.post(Uri.parse('http://localhost:4000/get-restaurants'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body);

  return jsonDecode(response.body)['restaurants'];
}

class _RestaurantsState extends State<Restaurants> {
  var query = '', sort = 'friendliness', search = false;

  final ScrollController _scrollController = ScrollController();
  var page = 1;
  final _formKey = GlobalKey<FormState>();
  var formVal;

  // final _biggerFont = const TextStyle(fontSize: 18);

  final fieldText = TextEditingController();
  final searchResultsController = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var mobile = width < 500 ? true : false;
    debugPrint("ADHGKSLJDHF ${widget.zipCode}");
    var zipCode = widget.zipCode;
    debugPrint('$page');
    isDisabled() {
      if (page == 1) {
        return true;
      } else {
        return false;
      }
    }

    return Column(children: [
      // search/sort
      Container(
          height: height / 10,
          child: Row(
            children: [
              // sort
              Row(
                children: [
                  Container(
                      padding: EdgeInsets.only(
                          left: height / 40, right: height / 100),
                      child: Text("Sort by:")),
                  Container(
                      padding: EdgeInsets.only(right: height / 40),
                      child: DropdownButton(
                        value: sort,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 20,
                        elevation: 16,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            debugPrint('changed $value');
                            sort = value!;
                            page = 1;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                              value: 'friendliness',
                              child: Text('friendliness',
                                  style: TextStyle(color: AppColors.darkGrey))),
                          DropdownMenuItem<String>(
                              value: '# of meatless dishes',
                              child: Text('meatless dishes',
                                  style: TextStyle(color: AppColors.darkGrey)))
                        ],
                      ))
                ],
              ),

              // search
              Container(
                  padding:
                      EdgeInsets.only(bottom: height / 80, top: height / 100),
                  height: mobile ? height / 16 : height / 17,
                  width: mobile ? width / 4 : width / 5,
                  // search form
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
                            hintStyle: TextStyle(fontSize: 12),
                            hintText: search ? '$query' : 'search'),
                        onSaved: (value) {
                          if (value is String) {
                            formVal = value;
                          }
                        },
                        onFieldSubmitted: (val) {
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
                        }),
                  )),
              // search button
              Container(
                  padding:
                      EdgeInsets.only(bottom: height / 80, top: height / 100),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          side: BorderSide(
                              width: mobile ? 1 : 2, color: AppColors.medGrey),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(7),
                                bottomRight: Radius.circular(7)),
                          ),
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
          )),
      // divider
      if (mobile) Container(height: 1, color: AppColors.medGrey),

      // restaurants
      Container(
        height: mobile ? height * (3 / 5) : (height) * (13 / 20),
        color: mobile ? null : AppColors.lightestGrey,
        child: Center(
            child: FutureBuilder<List>(
          future: getRestaurants(page, zipCode, sort, search, query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data![0] == 'no results') {
                return Text('no results');
              } else {
                if (width < 500) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, int position) {
                      if (snapshot.data![position]["friendliness"] != null &&
                          snapshot.data![position]["friendliness"] != 'N/A') {
                        snapshot.data![position]["friendliness"] =
                            snapshot.data![position]["friendliness"].round();
                      } else {
                        snapshot.data![position]["friendliness"] = 0;
                      }
                      return RestaurantCard(
                        pins: widget.pins,
                        notifyMain: widget.notifyParent,
                        restaurant: snapshot.data![position],
                        pinsOnDisplay: widget.pinsOnDisplay,
                      );
                    },
                  );
                } else {
                  return Padding(
                      padding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          mainAxisExtent: 250,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          maxCrossAxisExtent: 220,

                          // crossAxisCount:
                          //     calculateCount(MediaQuery.of(context).size),
                        ),
                        controller: _scrollController,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (_, int position) {
                          if (snapshot.data![position]["end"] == true) {
                            return Text('End of results');
                          } else {
                            debugPrint(
                                'type ${snapshot.data![position]["friendliness"]}');
                            if (snapshot.data![position]["friendliness"] !=
                                    null &&
                                snapshot.data![position]["friendliness"] !=
                                    'N/A') {
                              snapshot.data![position]["friendliness"] =
                                  snapshot.data![position]["friendliness"]
                                      .round();
                            } else {
                              snapshot.data![position]["friendliness"] = 0;
                            }
                            return RestaurantCard(
                              pins: widget.pins,
                              notifyMain: widget.notifyParent,
                              restaurant: snapshot.data![position],
                              pinsOnDisplay: widget.pinsOnDisplay,
                            );
                          }
                        },
                      ));
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
      if (mobile) Container(height: 1, color: AppColors.medGrey),

      // page
      Container(
          padding: EdgeInsets.only(top: height / 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isDisabled())
                IconButton(
                    hoverColor: AppColors.noHover,
                    onPressed: () async {
                      setState(() {
                        page = page - 1;
                      });
                      await Future.delayed(const Duration(milliseconds: 200));
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
                        contentPadding: EdgeInsets.only(bottom: 1, left: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.medGrey, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.lightGrey, width: 1),
                        ),
                        hintText: '$page',
                        hintStyle: TextStyle(fontSize: 12)),
                  )),
              FutureBuilder<List>(
                future: getRestaurants(page, zipCode, sort, search, query),
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
                          onPressed: () async {
                            setState(() {
                              page = page + 1;
                            });
                            await Future.delayed(
                                const Duration(milliseconds: 200));
                            SchedulerBinding.instance
                                ?.addPostFrameCallback((timeStamp) {
                              _scrollController.animateTo(
                                  _scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 10),
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
    ]);
  }
}
