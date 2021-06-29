import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'itemDialog.dart';
import 'pinnedItems.dart';

class RestaurantPage extends StatefulWidget {
  var info;
  var pins;

  RestaurantPage({Key? key, @required this.info, this.pins}) : super(key: key);

  _RestaurantPageState createState() => _RestaurantPageState();
}

Future<List> getPageDishes(id) async {
  final String body = jsonEncode({"id": id});
  final response =
      await http.post(Uri.parse('http://localhost:4000/get-page-dishes'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body);

  return jsonDecode(response.body)['dishes'];
}

// stuff for restaurant page

class _RestaurantPageState extends State<RestaurantPage> {
  late Future<List> _dishes;

  void initState() {
    super.initState();
    _dishes = getPageDishes(widget.info['id']);

    // debugPrint('$_restaurants');
  }

  Widget itemDesc(item) {
    var name = item['name'],
        description = item['description'],
        image = item['images'],
        pinned = item['pinned'],
        id = item['_id'];

    final height = MediaQuery.of(context).size.height,
        width = MediaQuery.of(context).size.width;

    if (description.length > 80) {
      description = description.substring(0, 80);
      description = description + "...";
    }

    if (image != 'none') {
      image = image.split(" 1920w,");
      image = image[0];

      image = image.split(
          'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/');

      image = image[1];
    }
    // var descriptionExists;
    // if (description == 'nu')
    return InkWell(
      child: Card(
          child: Column(children: [
        if (image != 'none')
          Container(
            height: width / 10,
            child: Image.network(image),
          ),
        Text(name,
            style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: height / 55),
            textAlign: TextAlign.center),
        if (description != 'none')
          Text(description,
              style: TextStyle(color: Colors.grey[800], fontSize: height / 60),
              textAlign: TextAlign.center),
        IconButton(
            onPressed: !pinned
                ? () {
                    debugPrint('pressed');
                    var temp = widget.pins;

                    temp['ids'].add(id);
                    temp['items'].add(item);
                    debugPrint('$temp');

                    setState(() {
                      // debugPrint('setting state');
                      widget.pins = temp;
                    });
                  }
                : () {
                    debugPrint('pressed');
                    var temp = widget.pins;
                    debugPrint('$temp');
                    temp['ids'].remove(id);
                    for (var i = 0; i < temp['items'].length; i++) {
                      if (temp['items'][i] == id) {
                        temp['items'].removeAt(i);
                        break;
                      }
                    }
                    setState(() {
                      // debugPrint('setting state');
                      widget.pins = temp;
                    });
                  },
            icon: pinned ? Icon(Icons.star) : Icon(Icons.star_border))
      ])),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ItemDialog(pins: widget.pins, item: item);
            }).then((val) => setState(() {}));
      },
    );
  }

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
        body: FutureBuilder<List>(
            future: _dishes,
            builder: (context, snapshot) {
              Widget restaurantName = SliverToBoxAdapter(
                  child: Text('${widget.info['name']}',
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 30)));
              Widget main = SliverToBoxAdapter(child: Text('')),
                  side = SliverToBoxAdapter(child: Text('')),
                  sides = SliverToBoxAdapter(child: Text('')),
                  dessert = SliverToBoxAdapter(child: Text('')),
                  desserts = SliverToBoxAdapter(child: Text(''));
              Widget mains = SliverToBoxAdapter(
                  child: SizedBox(
                child: CircularProgressIndicator(),
                height: 50.0,
                width: 50.0,
              ));
              debugPrint('$snapshot');
              if (snapshot.hasData) {
                for (var i = 0; i < snapshot.data!.length; i++) {
                  for (var j = 0; j < snapshot.data![i].length; j++) {
                    var itemId = snapshot.data![i][j]["_id"];

                    if (widget.pins['ids'].contains(itemId)) {
                      snapshot.data![i][j]['pinned'] = true;
                    } else {
                      snapshot.data![i][j]['pinned'] = false;
                    }
                  }
                }
                main = SliverToBoxAdapter(child: Text('Mains'));
                mains = SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250.0,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: (1.3 / 1.5),
                  ),
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return itemDesc(snapshot.data![0][index]);
                  }, childCount: snapshot.data![0].length),
                );
                if (snapshot.data![1].length > 0) {
                  side = SliverToBoxAdapter(child: Text('Sides'));
                  sides = SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: (1.3 / 1.5),
                    ),
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return itemDesc(snapshot.data![1][index]);
                    }, childCount: snapshot.data![1].length),
                  );
                }

                if (snapshot.data![2].length > 0) {
                  dessert = SliverToBoxAdapter(child: Text('Desserts'));
                  desserts = SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: (1.3 / 1.5),
                    ),
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return itemDesc(snapshot.data![2][index]);
                    }, childCount: snapshot.data![2].length),
                  );
                }
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return CustomScrollView(
                slivers: <Widget>[
                  restaurantName,
                  main,
                  mains,
                  side,
                  sides,
                  dessert,
                  desserts
                ],
              );

              // By default, show a loading spinner.
              // return Text("AHH");
            }));
  }
}
