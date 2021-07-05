import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'itemDialog.dart';

class Dishes extends StatefulWidget {
  var pins;
  var zipCode;
  var search = false;
  var query = '';

  Dishes({this.pins, this.zipCode});
  _DishesState createState() => _DishesState();
}

Future<List> getDishes(offset, zipCode, search, query) async {
  final String body = jsonEncode(
      {"offset": offset, 'zipCode': zipCode, 'search': search, 'query': query});
  final response =
      await http.post(Uri.parse('http://localhost:4000/get-dishes'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: body);

  // if (response.body.length > 100) {
  return jsonDecode(response.body)['dishes'];
  // }
}

class _DishesState extends State<Dishes> {
  late Future<List> _dishes;
  var page = 1;

  final _formKey = GlobalKey<FormState>();
  var formVal;

  final fieldText = TextEditingController();
  final searchResultsController = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  void initState() {
    super.initState();
    _dishes = getDishes(page, widget.zipCode, widget.search, widget.query);
  }

  Widget dishDesc(item) {
    var name = item['name'],
        description = item['description'],
        image = item['images'],
        // price = item['price'],
        pinned = item['pinned'],
        // restaurant = item['restuarant_name'],
        id = item['_id'];
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return ItemDialog(pins: widget.pins, item: item);
              }).then((val) => setState(() {}));
        },
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
                style:
                    TextStyle(color: Colors.grey[800], fontSize: height / 60),
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
                        widget.pins = temp;
                      });
                    }
                  : () {
                      debugPrint('pressed');
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
              icon: pinned ? Icon(Icons.star) : Icon(Icons.star_border))
        ])));

    // USE FOR MOBILE INTERFACE LATER ON
    // return new ListTile(
    //   leading: Container(
    //     child: Column(
    //       children: [
    //         if (image != 'none')
    //           Container(
    //             height: MediaQuery.of(context).size.height / 17,
    //             child: Image.network(image),
    //           )
    //       ],
    //     ),
    //   ),
    //   title: Text(name),
    //   subtitle: description == 'none' ? null : Text(description),
    //   // trailing: Icon(Icons.star)
    //   // Star(pinned: alreadyPinned)
    // );
  }

  Widget build(BuildContext context) {
    debugPrint('$page');
    isDisabled() {
      if (page == 1) {
        return true;
      } else {
        return false;
      }
    }

    calculateCount(size) {
      if (size.width < 480) {
        return 2;
      } else if (size.width < 767) {
        return 3;
      } else if (size.width < 991) {
        return 4;
      } else {
        return 5;
      }
    }

    return Scaffold(
        body: Column(children: [
      Row(
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.width / 4,
              child: Form(
                key: _formKey,
                child: TextFormField(
                    controller: searchResultsController,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: widget.search
                            ? '${widget.query}'
                            : 'search within results'),
                    onSaved: (value) {
                      if (value is String) {
                        formVal = value;
                      }
                    }),
              )),
          ElevatedButton(
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
              child: widget.search ? Text('Clear') : Text('Search'))
        ],
      ),
      SizedBox(
        height: (MediaQuery.of(context).size.height) * (3 / 5),
        child: Center(
            child: FutureBuilder<List>(
          future: getDishes(page, widget.zipCode, widget.search, widget.query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length < 8) {
                snapshot.data!.add('end');
              }

              // labels items from snapshot as pinned/not based on state
              for (var i = 0; i < snapshot.data!.length; i++) {
                var itemId = snapshot.data![i]["_id"];

                if (widget.pins['ids'].contains(itemId)) {
                  snapshot.data![i]['pinned'] = true;
                } else {
                  snapshot.data![i]['pinned'] = false;
                }
              }
              return GridView.builder(
                itemCount: snapshot.data!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: calculateCount(MediaQuery.of(context).size),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: (1.3 / 1.5),
                ),
                itemBuilder: (_, int position) {
                  if (snapshot.data![position] != 'end') {
                    return dishDesc(snapshot.data![position]);
                  } else {
                    return Text('End of results');
                  }
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return SizedBox(
              child: CircularProgressIndicator(),
              height: 50.0,
              width: 50.0,
            );
          },
        )),
      ),
      Row(
        children: [
          ElevatedButton(
              onPressed: isDisabled()
                  ? null
                  : () => {
                        setState(() {
                          page = page - 1;
                        })
                      },
              child: Text('Prev')),
          Container(
              child: TextField(
                controller: fieldText,
                onSubmitted: (value) {
                  var number = int.tryParse(value);
                  if (number != null && 0 < number && number < 3937) {
                    setState(() {
                      page = number;
                    });

                    clearText();
                  }
                },
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), hintText: '$page'),
              ),
              width: 50),
          FutureBuilder<List>(
            future: _dishes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ElevatedButton(
                    onPressed: snapshot.data!.length < 7
                        ? null
                        : () => {
                              setState(() {
                                page = page + 1;
                              })
                            },
                    child: Text('Next'));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return Text('');
              }
            },
          ),
        ],
      )
    ]));
  }
}
