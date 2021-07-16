// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

import 'restaurantPage.dart';
import 'itemDialog.dart';
import 'appColors.dart';

class PinnedItems extends StatefulWidget {
  var pins;

  PinnedItems({this.pins});

  _PinnedItemsState createState() => _PinnedItemsState();
}

class _PinnedItemsState extends State<PinnedItems> {
  sortByRestaurant(items) {
    var idsSeen = <String>{};
    var preSorted = {};

    debugPrint('$items');
    for (var i = 0; i < items.length; i++) {
      if (idsSeen.contains(items[i]["restaurant_id"])) {
        preSorted[items[i]['restuarant_name']].add(items[i]);
      } else {
        idsSeen.add(items[i]["restaurant_id"]);
        preSorted[items[i]['restuarant_name']] = [items[i]];
      }
      debugPrint('$preSorted, $idsSeen, AAHHH');
    }

    debugPrint('$preSorted');

    var sorted = [];

    preSorted.forEach((key, value) {
      var id = value[0]["restaurant_id"];
      var newObject = {'id': id, 'name': key};
      value.insert(0, newObject);
      sorted.add(value);
    });

    return sorted;
  }

  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height;
    var items = sortByRestaurant(widget.pins['items']);

    return Scaffold(
        backgroundColor: Colors.white,
        // app bar
        appBar: AppBar(
          // bottom: PreferredSize(
          //     child: Container(
          //       color: AppColors.lightGrey,
          //       height: 1.0,
          //     ),
          //     preferredSize: Size.fromHeight(1.0)),
          elevation: 0,
          iconTheme: IconThemeData(
            color: AppColors.medGrey, //change your color here
          ),
          title: Container(
              padding: EdgeInsets.only(bottom: height / 150, top: height / 150),
              child: Text('Starred Dishes',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: width < 500 ? 20 : height / 40))),
        ),
        // starred dishes display
        body: Container(
            padding: EdgeInsets.all(10),
            child: CustomScrollView(
              slivers: [
                if (items.length == 0)
                  SliverToBoxAdapter(
                      child: Container(
                          padding: EdgeInsets.only(top: 20),
                          height: height / 3,
                          width: width,
                          child: Text(
                            "star dishes you're interested in!",
                            style: TextStyle(
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w600,
                                fontSize: width < 500 ? 18 : height / 60),
                            textAlign: TextAlign.center,
                          ))),
                for (var itemList in items)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      debugPrint('$itemList');

                      if (index == 0) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.only(bottom: 10, top: 20),
                                  child: InkWell(
                                      child: Text('${itemList[index]['name']}',
                                          style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => RestaurantPage(
                                                  info: itemList[0],
                                                  pins: widget.pins)),
                                        );
                                      })),
                              Container(
                                  width: width - 10,
                                  height: 1,
                                  color: AppColors.lightGrey)
                            ]);
                      } else {
                        var image = itemList[index]['images'],
                            name = itemList[index]['name'],
                            description = itemList[index]['description'],
                            id = itemList[index]['_id'],
                            price = itemList[index]['price'];

                        if (image != 'none') {
                          image = image.split(" 1920w,");
                          image = image[0];

                          image = image.split(
                              'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/');

                          image = image[1];
                        }
                        return InkWell(
                            hoverColor: AppColors.noHover,
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ItemDialog(
                                        pins: widget.pins,
                                        item: itemList[index]);
                                  }).then((val) => setState(() {}));
                            },
                            child: Container(
                                height: height / 5 + 2.5,
                                child: Column(children: [
                                  Container(
                                      padding: EdgeInsets.only(
                                          top: 5, bottom: 15, left: 10),
                                      // contents of card
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // text
                                            Container(
                                                padding:
                                                    EdgeInsets.only(left: 5),
                                                child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      // dish name
                                                      Container(
                                                          width:
                                                              width * (2 / 3),
                                                          child: Text(
                                                            name,
                                                            style: AppStyles
                                                                .header,
                                                            textAlign:
                                                                TextAlign.left,
                                                          )),
                                                      // dish description if it exists
                                                      if (description != 'none')
                                                        Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        8),
                                                            width:
                                                                width * (2 / 3),
                                                            child: Text(
                                                              description,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: AppStyles
                                                                  .subtitle,
                                                            )),
                                                      // dish price and restaurant
                                                      Container(
                                                          width:
                                                              width * (2 / 3),
                                                          child: Text(
                                                            '$price',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .accent),
                                                          ))
                                                    ])),
                                            // image if it exists
                                            if (image != 'none')
                                              Container(
                                                  height: height / 6 + 8,
                                                  width: height / 3 - 10,
                                                  child: Card(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Image.network(
                                                          image,
                                                          alignment: Alignment
                                                              .topCenter,
                                                          fit: BoxFit.fitWidth,
                                                          width: height / 3,
                                                          height: height / 6,
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            // placeholder image if image does not exist
                                            if (image == 'none')
                                              Container(
                                                  decoration: BoxDecoration(
                                                      color: AppColors.medGrey,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5))),
                                                  height: height / 6 - 5,
                                                  width: height / 3 - 10,
                                                  child: Center(
                                                      child: Text('no image',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)))),
                                            Container(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: IconButton(
                                                    onPressed: () {
                                                      var temp = widget.pins;
                                                      debugPrint('$temp');
                                                      temp['ids'].remove(id);
                                                      for (var i = 0;
                                                          i <
                                                              temp['items']
                                                                  .length;
                                                          i++) {
                                                        if (temp['items'][i]
                                                                ['_id'] ==
                                                            id) {
                                                          temp['items']
                                                              .removeAt(i);
                                                          break;
                                                        }
                                                      }
                                                      setState(() {
                                                        debugPrint(
                                                            'setting state');
                                                        widget.pins = temp;
                                                      });
                                                    },
                                                    icon: Icon(Icons.cancel,
                                                        color: AppColors
                                                            .darkGrey))),
                                          ])),
                                  // divider
                                  Container(
                                      width: width - 10,
                                      height: 1,
                                      color: AppColors.lightGrey)
                                ])));
                      }
                    }, childCount: itemList.length),
                    // itemExtent: MediaQuery.of(context).size.height / 10
                  )
              ],
            )));
  }
}
