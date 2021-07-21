import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'itemDialog.dart';
import 'appColors.dart';
import 'pinnedItems.dart';

class Header extends StatelessWidget {
  final maxHeight;
  final minHeight;
  final image;
  final name;

  const Header({key, this.maxHeight, this.minHeight, this.image, this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expandRatio = _calculateExpandRatio(constraints);
        final animation = AlwaysStoppedAnimation(expandRatio);

        return Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            _buildGradient(animation),
            _buildTitle(animation),
          ],
        );
      },
    );
  }

  double _calculateExpandRatio(BoxConstraints constraints) {
    var expandRatio =
        (constraints.maxHeight - minHeight) / (maxHeight - minHeight);
    if (expandRatio > 1.0) expandRatio = 1.0;
    if (expandRatio < 0.0) expandRatio = 0.0;
    return expandRatio;
  }

  Align _buildTitle(Animation<double> animation) {
    return Align(
      alignment: AlignmentTween(
              begin: Alignment.bottomCenter, end: Alignment.bottomLeft)
          .evaluate(animation),
      child: Container(
        margin: EdgeInsets.only(bottom: 12, left: 12),
        child: Text(
          name,
          style: TextStyle(
            fontSize: Tween<double>(begin: 18, end: 36).evaluate(animation),
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Container _buildGradient(Animation<double> animation) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withAlpha(0),
            Colors.black12,
            Colors.black45
          ],
        ),
      ),
    );
  }

  Image _buildImage() {
    return Image.network(
      image,
      fit: BoxFit.cover,
    );
  }
}

class RestaurantPage extends StatefulWidget {
  final info;
  final pins;

  RestaurantPage({Key? key, @required this.info, this.pins}) : super(key: key);

  _RestaurantPageState createState() => _RestaurantPageState();
}

Future<List> getPageDishes(id) async {
  final String body = jsonEncode({"id": id});
  final response =
      // for local android dev
      await http.post(Uri.parse('http://10.0.2.2:4000/get-page-dishes'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body);

  // for local ios + browser dev
  // await http.post(Uri.parse('http://localhost:4000/get-page-dishes'),
  //     headers: {
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //     },
  //     body: body);

  return jsonDecode(response.body)['dishes'];
}

// stuff for restaurant page

class _RestaurantPageState extends State<RestaurantPage> {
  var pins;
  late Future<List> _dishes;

  void initState() {
    super.initState();
    _dishes = getPageDishes(widget.info['id']);

    // debugPrint('$_restaurants');
  }

  Widget itemDesc(item, currentPins) {
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
                    var temp = currentPins;

                    temp['ids'].add(id);
                    temp['items'].add(item);
                    debugPrint('$temp');

                    setState(() {
                      // debugPrint('setting state');
                      pins = temp;
                    });
                  }
                : () {
                    debugPrint('pressed');
                    var temp = currentPins;
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
                      pins = temp;
                    });
                  },
            icon: pinned ? Icon(Icons.star) : Icon(Icons.star_border))
      ])),
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ItemDialog(pins: currentPins, item: item);
            }).then((val) => setState(() {}));
      },
    );
  }

  Widget build(BuildContext context) {
    var maxHeight = 250 + MediaQuery.of(context).padding.top;

    var minHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    pins = widget.pins;
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Meatless'),
        //   actions: [
        //     IconButton(
        //         onPressed: () {
        //           Navigator.push(
        //             context,
        //             MaterialPageRoute(builder: (_) => PinnedItems(pins: pins)),
        //           ).then((val) => setState(() {}));
        //         },
        //         icon: Icon(Icons.star))
        //   ],
        // ),
        body: FutureBuilder<List>(
            future: _dishes,
            builder: (context, snapshot) {
              Widget main = SliverToBoxAdapter(child: Text('')),
                  side = SliverToBoxAdapter(child: Text('')),
                  sides = SliverToBoxAdapter(child: Text('')),
                  dessert = SliverToBoxAdapter(child: Text('')),
                  desserts = SliverToBoxAdapter(child: Text('')),
                  drink = SliverToBoxAdapter(child: Text('')),
                  drinks = SliverToBoxAdapter(child: Text(''));

              Widget mains = SliverToBoxAdapter(
                  child: SizedBox(
                child: CircularProgressIndicator(),
                height: 50.0,
                width: 50.0,
              ));

              if (snapshot.hasData) {
                for (var i = 0; i < snapshot.data!.length - 1; i++) {
                  for (var j = 0; j < snapshot.data![i].length; j++) {
                    var itemId = snapshot.data![i][j]["_id"];

                    if (pins['ids'].contains(itemId)) {
                      snapshot.data![i][j]['pinned'] = true;
                    } else {
                      snapshot.data![i][j]['pinned'] = false;
                    }
                  }
                }

                // mains
                if (snapshot.data![0].length > 0) {
                  main = SliverToBoxAdapter(child: Text('Mains'));
                  mains = SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: (1.3 / 1.5),
                    ),
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return itemDesc(snapshot.data![0][index], pins);
                    }, childCount: snapshot.data![0].length),
                  );
                }
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
                      return itemDesc(snapshot.data![1][index], pins);
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
                      return itemDesc(snapshot.data![2][index], pins);
                    }, childCount: snapshot.data![2].length),
                  );
                }

                if (snapshot.data![3].length > 0) {
                  drink = SliverToBoxAdapter(child: Text('Drinks'));
                  drinks = SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: (1.3 / 1.5),
                    ),
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return itemDesc(snapshot.data![3][index], pins);
                    }, childCount: snapshot.data![3].length),
                  );
                }
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    elevation: 3,
                    stretch: true,
                    pinned: true,
                    snap: true,
                    floating: true,
                    expandedHeight: 250,
                    flexibleSpace: snapshot.hasData
                        ? Header(
                            maxHeight: maxHeight,
                            minHeight: minHeight,
                            image: snapshot.data![4]['image'],
                            name: widget.info['name'],
                          )
                        : null,
                    iconTheme: IconThemeData(
                      color: AppColors.medGrey, //change your color here
                    ),
                    // titleTextStyle: TextStyle(color: Colors.black),
                  ),
                  main,
                  mains,
                  side,
                  sides,
                  dessert,
                  desserts,
                  drink,
                  drinks,
                ],
              );

              // By default, show a loading spinner.
              // return Text("AHH");
            }));
  }
}
