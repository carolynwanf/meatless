// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

import 'restaurantPage.dart';
import 'itemDialog.dart';

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
    var items = sortByRestaurant(widget.pins['items']);

    return Scaffold(
        appBar: AppBar(
          title: Text('Meatless'),
          actions: [IconButton(onPressed: null, icon: Icon(Icons.star))],
        ),
        body: CustomScrollView(
          slivers: [
            if (items.length == 0)
              SliverToBoxAdapter(child: Text('No pins yet!')),
            for (var itemList in items)
              SliverFixedExtentList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    debugPrint('$itemList');

                    if (index == 0) {
                      return Container(
                          child: InkWell(
                              child: Text('${itemList[index]['name']}',
                                  style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.height /
                                              30)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RestaurantPage(
                                          info: itemList[0],
                                          pins: widget.pins)),
                                );
                              }),
                          alignment: Alignment.bottomLeft);
                    } else {
                      var image = itemList[index]['images'],
                          // name = itemList[index]['name'],
                          description = itemList[index]['description'],
                          id = itemList[index]['_id'];
                      if (image != 'none') {
                        image = image.split(" 1920w,");
                        image = image[0];

                        image = image.split(
                            'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/');

                        image = image[1];
                      }
                      return Card(
                          child: ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ItemDialog(
                                    pins: widget.pins, item: itemList[index]);
                              }).then((val) => setState(() {}));
                        },
                        leading: Container(
                            child: Column(
                          children: [
                            if (image != 'none')
                              Container(
                                height: MediaQuery.of(context).size.height / 17,
                                child: Image.network(image),
                              )
                          ],
                        )),
                        title: Text(itemList[index]['name']),
                        subtitle: description.length == 'none'
                            ? null
                            : Text(description),
                        trailing: IconButton(
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
                            },
                            icon: Icon(Icons.cancel)),
                      ));
                    }
                  }, childCount: itemList.length),
                  itemExtent: MediaQuery.of(context).size.height / 10)
          ],
        ));
  }
}
