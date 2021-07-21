// import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

import 'restaurantPage.dart';
import 'itemDialog.dart';
import 'appColors.dart';

class PinnedItems extends StatefulWidget {
  var pins;
  var notifyMain;

  PinnedItems({this.pins, this.notifyMain});

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

  Widget starredDish(item) {
    var image = item['images'],
        name = item['name'],
        description = item['description'],
        id = item['_id'],
        price = item['price'];

    if (description.length > 50) {
      description = description.substring(0, 50);
      description = description + "...";
    }

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
                return ItemDialog(pins: widget.pins, item: item);
              }).then((val) => setState(() {}));
        },
        child: Container(
            child: Column(children: [
          Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
              // contents of card
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                // text
                Expanded(
                    flex: 6,
                    child: Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // dish name
                              Text(
                                name,
                                style: AppStyles.header,
                                textAlign: TextAlign.left,
                              ),
                              // dish description if it exists
                              if (description != 'none')
                                Container(
                                    // height: 60,
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      description,
                                      textAlign: TextAlign.left,
                                      style: AppStyles.subtitle,
                                    )),
                              // dish price
                              Text(
                                '$price',
                                textAlign: TextAlign.left,
                                style: TextStyle(color: AppColors.accent),
                              )
                            ]))),
                // image if it exists
                if (image != 'none' && MediaQuery.of(context).size.width < 500)
                  Expanded(
                      flex: 2,
                      child: Container(
                          height: 100,
                          width: 100,
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
                                  width: 100,
                                  height: 100,
                                ),
                              ],
                            ),
                          ))),
                // placeholder image if image does not exist
                // if (image == 'none')
                //   Container(
                //       decoration: BoxDecoration(
                //           color: AppColors.medGrey,
                //           borderRadius:
                //               BorderRadius.all(
                //                   Radius.circular(5))),
                //       height: 100,
                //       width: 100,
                //       child: Center(
                //           child: Text('no image',
                //               style: TextStyle(
                //                   color:
                //                       Colors.white)))),
                Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.only(left: 0),
                        child: IconButton(
                            onPressed: () {
                              var temp = widget.pins;
                              debugPrint('$temp');
                              temp['ids'].remove(id);
                              for (var i = 0; i < temp['items'].length; i++) {
                                if (temp['items'][i]['_id'] == id) {
                                  temp['items'].removeAt(i);
                                  break;
                                }
                              }
                              setState(() {
                                debugPrint('setting state');
                                widget.pins = temp;
                              });

                              widget.notifyMain();
                            },
                            icon:
                                Icon(Icons.cancel, color: AppColors.medGrey)))),
              ])),
          // divider
          Container(
              width: MediaQuery.of(context).size.width - 10,
              height: 1,
              color: AppColors.lightGrey)
        ])));
  }

  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width > 500
            ? MediaQuery.of(context).size.width * (9 / 40)
            : MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height;
    var items = sortByRestaurant(widget.pins['items']);

    return Scaffold(
        backgroundColor: Colors.white,
        // app bar
        appBar: MediaQuery.of(context).size.width > 1000
            ? null
            : AppBar(
                elevation: 0,
                iconTheme: IconThemeData(
                  color: AppColors.medGrey, //change your color here
                ),
                title: Container(
                    padding: EdgeInsets.only(
                        bottom: height / 150, top: height / 150),
                    child: Text('Starred Dishes',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 20))),
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
                                fontSize: 15),
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
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
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
                                  width: MediaQuery.of(context).size.width -
                                      10 -
                                      10,
                                  height: 1,
                                  color: AppColors.lightGrey)
                            ]);
                      } else {
                        return starredDish(itemList[index]);
                      }
                    }, childCount: itemList.length),
                    // itemExtent: MediaQuery.of(context).size.height / 10
                  )
              ],
            )));
  }
}
