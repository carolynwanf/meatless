import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'restaurantPage.dart';

class Restaurants extends StatefulWidget {
  var pins;
  var zipCode;

  Restaurants({this.pins, this.zipCode});
  @override
  _RestaurantsState createState() => _RestaurantsState();
}

Future<List> getRestaurants(offset, zipCode) async {
  debugPrint('getting restaurants, $zipCode');

  final String body = jsonEncode({"offset": offset, 'zipCode': zipCode});
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
  late Future<List> _restaurants;
  var page = 1;

  // final _biggerFont = const TextStyle(fontSize: 18);

  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  void initState() {
    var zipCode = widget.zipCode;
    super.initState();
    debugPrint('debug printing');
    _restaurants = getRestaurants(page, zipCode);

    // debugPrint('$_restaurants');
  }

  Widget restaurantDesc(name, type, friendliness, id) {
    final _iconSize = const TextStyle(fontSize: 30);

    var info = {'name': name, 'id': id};

    return new ListTile(
      leading: Text('${friendliness}', style: _iconSize),
      title: Text(name),
      subtitle: Text(type),
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RestaurantPage(info: info, pins: widget.pins)),
        )
      },
      // trailing: Icon(Icons.star)
      // Star(pinned: alreadyPinned)
    );
  }

  @override
  Widget build(BuildContext context) {
    var zipCode = widget.zipCode;
    debugPrint('$page');
    isDisabled() {
      if (page == 1) {
        return true;
      } else {
        return false;
      }
    }

    return Scaffold(
        body: Column(children: [
      SizedBox(
        height: (MediaQuery.of(context).size.height) * (7 / 10),
        child: Center(
            child: FutureBuilder<List>(
          future: getRestaurants(page, zipCode),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              debugPrint('${snapshot.data}');
              if (snapshot.data![0] != 'no results') {
                while (snapshot.data![snapshot.data!.length - 1]
                            ["friendliness"] ==
                        null &&
                    snapshot.data![snapshot.data!.length - 2]["friendliness"] ==
                        null) {
                  snapshot.data!.removeAt(snapshot.data!.length - 1);
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, int position) {
                    if (snapshot.data![position]["friendliness"] == null) {
                      return Text('End of results');
                    } else {
                      return Card(
                          child: restaurantDesc(
                              snapshot.data![position]["name"],
                              snapshot.data![position]["type"],
                              snapshot.data![position]["friendliness"]
                                  .roundToDouble(),
                              snapshot.data![position]["_id"]));
                    }
                  },
                );
              } else {
                return Text('no results');
              }
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
                          _restaurants = getRestaurants(page, zipCode);
                        })
                      },
              child: Text('Prev')),
          Container(
              child: TextField(
                controller: fieldText,
                onSubmitted: (value) {
                  var number = int.tryParse(value);
                  if (number != null && 0 < number && number < 118) {
                    setState(() {
                      page = number;
                      _restaurants = getRestaurants(number, zipCode);
                    });

                    clearText();
                  }
                },
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), hintText: '  $page'),
              ),
              width: 50),
          FutureBuilder<List>(
            future: _restaurants,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var nullfriendly = true;
                if (snapshot.data![0] != 'no results') {
                  for (var i = 0; i < snapshot.data!.length; i++) {
                    if (snapshot.data![i]['friendliness'] != null) {
                      nullfriendly = false;
                    }
                  }
                }
                return ElevatedButton(
                    onPressed: nullfriendly
                        ? null
                        : () => {
                              setState(() {
                                page = page + 1;
                                _restaurants = getRestaurants(page, zipCode);
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
