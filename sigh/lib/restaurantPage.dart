import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'itemDialog.dart';
import 'appColors.dart';
import 'pinnedItems.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

// collapsing header for mobile
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
        margin: EdgeInsets.only(bottom: 15, left: 12),
        child: Text(
          name,
          style: TextStyle(
            fontSize: Tween<double>(begin: 18, end: -70).evaluate(animation),
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Container _buildGradient(Animation<double> animation) {
    return Container(
      decoration: BoxDecoration(
          color: ColorTween(begin: Colors.white, end: Colors.white.withAlpha(0))
              .evaluate(animation)
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: <Color>[
          //     Colors.black.withAlpha(0),
          //     Colors.black12,
          //     Colors.black87
          //   ],
          // ),
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

// gets restaurant's dishes
Future<List> getPageDishes(id) async {
  final String body = jsonEncode({"id": id});
  final response =
      // for local android dev
      // await http.post(Uri.parse('http://10.0.2.2:4000/get-page-dishes'),
      //     headers: {
      //       'Accept': 'application/json',
      //       'Content-Type': 'application/json',
      //     },
      //     body: body);

      // for local ios + browser dev
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
  var starToast;

  @override
  void initState() {
    super.initState();
    starToast = FToast();
    _dishes = getPageDishes(widget.info['id']);
    starToast.init(context);
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

  refresh() {
    setState(() {
      pins = pins;
    });
  }

  var pins;

  Future<void> savePins(pins) async {
    final temp = jsonEncode(pins);
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('pins', temp);
    });
  }

  late Future<List> _dishes;

  Widget itemDesc(item, currentPins, width) {
    void showItemDesc() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return ItemDialog(pins: currentPins, item: item);
          }).then((val) => {setState(() {})});
    }

    var name = item['name'],
        description = item['description'],
        image = item['images'],
        pinned = item['pinned'],
        id = item['_id'],
        price = item['price'];

    if (name.length > 50) {
      name = name.substring(0, 50);
      name = name + "...";
    }

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

    if (width < 500) {
      // mobile dish card
      return Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: InkWell(
              hoverColor: AppColors.noHover,
              onTap: showItemDesc,
              onDoubleTap: !pinned
                  ? () {
                      var temp = currentPins;

                      temp['items'].add(item);
                      debugPrint('$temp');

                      setState(() {
                        pins = temp;
                        savePins(temp);
                      });

                      _showToast("Starred");
                    }
                  : () {
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

                      _showToast("Unstarred");
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
                                  )),
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
                                  child: Text('$price',
                                      textAlign: TextAlign.left,
                                      style: AppStyles.detailMobile))
                            ])),
                        // image if it exists
                        if (image != 'none')
                          Container(
                              height: height / 6 + 8,
                              width: width / 2 - 15,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Image.network(
                                      image,
                                      alignment: Alignment.topCenter,
                                      fit: BoxFit.cover,
                                      width: height / 4,
                                      height: height / 6,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Container(
                                            height: height / 6,
                                            width: height / 4,
                                            color: AppColors.lightGrey,
                                            child: Center(
                                                child: Text(
                                              "can't load image",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )));
                                      },
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
                                      BorderRadius.all(Radius.circular(5))),
                              height: height / 6 - 5,
                              width: width / 2 - 15,
                              child: Center(
                                  child: Text('no image',
                                      style: TextStyle(color: Colors.white))))
                      ],
                    )),
                // divider
                Container(
                    width: width - 10, height: 1, color: AppColors.lightGrey)
              ])));
    } else {
      // web dish card
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
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Container(
                                    height: height / 6,
                                    width: double.maxFinite,
                                    color: AppColors.lightGrey,
                                    child: Center(
                                        child: Text(
                                      "can't load image",
                                      style: TextStyle(color: Colors.white),
                                    )));
                              },
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
                    '$price',
                    textAlign: TextAlign.center,
                    style: AppStyles.detail,
                  ),
                ]),
                Positioned(
                    bottom: 10,
                    left: 5,
                    child: InkWell(
                        onTap: !pinned
                            ? () {
                                debugPrint('pressed');
                                var temp = currentPins;

                                temp['items'].add(item);
                                debugPrint('$temp');

                                setState(() {
                                  pins = temp;
                                  savePins(temp);
                                });
                              }
                            : () {
                                debugPrint('pressed');
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

  Widget webGrid(list, pins, width) {
    if (width > 500) {
      return SliverPadding(
          padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250.0,
              mainAxisExtent: 300,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Card(
                  elevation: 2, child: itemDesc(list[index], pins, width));
            }, childCount: list.length),
          ));
    } else {
      return SliverPadding(
          padding: EdgeInsets.only(bottom: 10),
          sliver: SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return itemDesc(list[index], pins, width);
            }, childCount: list.length),
          ));
    }
  }

  Widget makeRestaurantInfo(restaurant, width) {
    var friendliness = restaurant['friendliness'].round(),
        name = restaurant['name'],
        type = restaurant['type'],
        url = restaurant['url'];

    return SliverToBoxAdapter(
        child: Padding(
            padding: EdgeInsets.only(bottom: width < 500 ? 10 : 0),
            child: Container(
                padding: EdgeInsets.all(width < 500 ? 10 : 20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      SizedBox(
                          child: Text(
                        name,
                        style: AppStyles.bigTitle,
                      )),
                    ]),
                    SizedBox(
                      child: Text(
                        '$type ??? $friendliness% friendly',
                        style: AppStyles.subtitleMobile,
                      ),
                    )
                  ],
                ))));
  }

  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var mobile = width < 500 ? true : false;
    var imageExists = false;
    var maxHeight = 250 + MediaQuery.of(context).padding.top;

    var minHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

    pins = widget.pins == null
        ? {'ids': <String>{}, 'items': [], 'display': true}
        : widget.pins;
    return Scaffold(
        appBar: mobile
            ? null
            : AppBar(
                elevation: 0,
                bottom: PreferredSize(
                    child: Container(
                      color: AppColors.lightGrey,
                      height: 1.0,
                    ),
                    preferredSize: Size.fromHeight(1.0)),
                // iconTheme: IconThemeData(color: AppColors.medGrey),
                actions: [
                  Padding(
                      padding: EdgeInsets.only(right: 10, top: 12),
                      child: InkWell(
                          hoverColor: AppColors.noHover,
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
                                          notifyMain: refresh,
                                        )),
                              ).then((val) => setState(() {}));
                            }
                          },
                          child: Container(
                              height: 30,
                              width: 30,
                              child: Stack(
                                children: [
                                  Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 0, 0),
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      alignment: Alignment.center),
                                  Container(
                                      height: 30,
                                      width: 30,
                                      child: Icon(Icons.star,
                                          color: pins["items"].length > 0
                                              ? AppColors.accent
                                              : AppColors.medGrey,
                                          size: 30),
                                      alignment: Alignment.center),
                                  if (pins['items'].length > 0)
                                    Container(
                                        height: 30,
                                        width: 30,
                                        child: Text('${pins['items'].length}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                        alignment: Alignment.center)
                                ],
                              ))))
                ],
                title: Text('MEATLESS',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20))

                // titleTextStyle: TextStyle(color: Colors.black),
                ),
        backgroundColor: mobile ? AppColors.lightestGrey : Colors.white,
        body: FutureBuilder<List>(
            future: _dishes,
            builder: (context, snapshot) {
              Widget placeholder = SliverToBoxAdapter(child: Container()),
                  appbar = placeholder,
                  headerImage = placeholder,
                  restaurantInfo = placeholder,
                  divider = placeholder,
                  main = placeholder,
                  side = placeholder,
                  sides = placeholder,
                  dessert = placeholder,
                  desserts = placeholder,
                  drink = placeholder,
                  drinks = placeholder;

              Widget mains = SliverToBoxAdapter(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: width,
                      child: Container(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                        height: 100.0,
                        width: 100.0,
                        alignment: Alignment.center,
                      )));

              if (snapshot.hasData) {
                var restaurant = snapshot.data![4];
                var pinnedIds = <String>{};

                for (var j = 0; j < pins['items'].length; j++) {
                  pinnedIds.add(pins['items'][j]['_id']);
                }
                // assigning dishes pinned status based on pinned state
                for (var i = 0; i < snapshot.data!.length - 1; i++) {
                  for (var j = 0; j < snapshot.data![i].length; j++) {
                    var itemId = snapshot.data![i][j]["_id"];

                    if (pinnedIds.contains(itemId)) {
                      snapshot.data![i][j]['pinned'] = true;
                    } else {
                      snapshot.data![i][j]['pinned'] = false;
                    }
                  }
                }

                // checking if restaurant has an image
                if (restaurant['image'] != null) {
                  imageExists = true;
                  if (!mobile) {
                    headerImage = SliverPadding(
                        padding: EdgeInsets.all(20),
                        sliver: SliverToBoxAdapter(
                            child: SizedBox(
                                height: 300,
                                child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    child: Image.network(
                                      restaurant['image'],
                                      fit: BoxFit.cover,
                                      height: 300,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Container(
                                            height: 300,
                                            color: AppColors.lightGrey,
                                            child: Center(
                                                child: Text(
                                              "can't load image",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )));
                                      },
                                    )))));
                  }
                }

                // defining appbar
                if (mobile) {
                  appbar = SliverAppBar(
                    leading: Padding(
                        padding: EdgeInsets.fromLTRB(10, 12, 0, 0),
                        child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            hoverColor: AppColors.noHover,
                            child: Stack(
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                ),
                                Container(
                                  height: 30,
                                  width: 30,
                                  child: Icon(Icons.arrow_back,
                                      color: Colors.black),
                                  alignment: Alignment.center,
                                )
                              ],
                            ))),

                    actions: [
                      Padding(
                          padding: EdgeInsets.only(right: 10, top: 12),
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
                                              notifyMain: refresh,
                                            )),
                                  ).then((val) => setState(() {}));
                                }
                              },
                              child: Container(
                                  height: 30,
                                  width: 30,
                                  child: Stack(
                                    children: [
                                      Container(
                                          padding:
                                              EdgeInsets.fromLTRB(10, 10, 0, 0),
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white),
                                          alignment: Alignment.center),
                                      Container(
                                          height: 30,
                                          width: 30,
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
                                            height: 30,
                                            width: 30,
                                            child: Text(
                                                '${pins['items'].length}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            alignment: Alignment.center)
                                    ],
                                  ))))
                    ],
                    elevation: 3,
                    stretch: true,
                    pinned: true,
                    title: imageExists ? null : Text(restaurant['name']),
                    expandedHeight: imageExists ? 250 : null,
                    flexibleSpace: imageExists
                        ? Header(
                            maxHeight: maxHeight,
                            minHeight: minHeight,
                            image: snapshot.data![4]['image'],
                            name: restaurant['name'],
                          )
                        : null,

                    // titleTextStyle: TextStyle(color: Colors.black),
                  );
                }

                // defining restaurant info

                restaurantInfo = makeRestaurantInfo(restaurant, width);

                divider = SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                        child:
                            Container(height: 1, color: AppColors.lightGrey)));

                Widget header(heading) {
                  return SliverToBoxAdapter(
                      child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.only(
                              left: width < 500 ? 10 : 20, top: 10, bottom: 5),
                          child: Text(heading, style: AppStyles.title)));
                }

                // mains
                if (snapshot.data![0].length > 0) {
                  main = header('Mains');
                  mains = webGrid(snapshot.data![0], pins, width);
                }
                if (snapshot.data![1].length > 0) {
                  side = header('Sides');
                  sides = webGrid(snapshot.data![1], pins, width);
                }

                if (snapshot.data![2].length > 0) {
                  dessert = header('Desserts');
                  desserts = webGrid(snapshot.data![2], pins, width);
                }

                if (snapshot.data![3].length > 0) {
                  drink = header('Drinks');
                  drinks = webGrid(snapshot.data![3], pins, width);
                }
              } else if (snapshot.hasError) {
                return Text("Server down, try again later");
              }

              return Row(children: [
                Expanded(
                  flex: 31,
                  child: CustomScrollView(
                    slivers: <Widget>[
                      appbar,
                      headerImage,
                      restaurantInfo,
                      if (width > 500) divider,
                      main,
                      mains,
                      side,
                      sides,
                      dessert,
                      desserts,
                      drink,
                      drinks,
                    ],
                  ),
                ),
                if (pins['display'] && width > 1000)
                  VerticalDivider(width: 1, color: AppColors.medGrey),
                if (pins['display'] && width > 1000)
                  Expanded(
                      flex: 9,
                      child: PinnedItems(
                        notifyMain: refresh,
                      ))
              ]);
            }));
  }
}
