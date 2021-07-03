import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'restaurantPage.dart';

class Restaurants extends StatefulWidget {
  var pins;
  var zipCode;
  var sort = 'friendliness';
  var search = false;
  var query = '';

  Restaurants({this.pins, this.zipCode});
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
  final _formKey = GlobalKey<FormState>();
  var formVal;

  // final _biggerFont = const TextStyle(fontSize: 18);

  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  void initState() {
    var zipCode = widget.zipCode;
    super.initState();
    debugPrint('debug printing');
    _restaurants =
        getRestaurants(page, zipCode, widget.sort, widget.search, widget.query);

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
      Container(
          height: MediaQuery.of(context).size.height / 10,
          child: Row(
            children: [
              DropdownButton(
                value: widget.sort,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? value) {
                  setState(() {
                    debugPrint('changed $value');
                    widget.sort = value!;
                    page = 1;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                      value: 'friendliness', child: Text('friendliness')),
                  DropdownMenuItem<String>(
                      value: '# of meatless dishes',
                      child: Text('# of meatless dishes'))
                ],
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height / 10,
                  width: MediaQuery.of(context).size.height / 10,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
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
                  onPressed: () {
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
                  child: Text('Search'))
            ],
          )),
      SizedBox(
        height: (MediaQuery.of(context).size.height) * (3 / 5),
        child: Center(
            child: FutureBuilder<List>(
          future: getRestaurants(
              page, zipCode, widget.sort, widget.search, widget.query),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              debugPrint('${widget.sort}');
              if (snapshot.data![0] != 'no results') {
                snapshot.data![snapshot.data!.length - 1]["end"] = true;

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, int position) {
                    if (snapshot.data![position]["end"] == true) {
                      return Text('End of results');
                    } else {
                      if (snapshot.data![position]["friendliness"].runtimeType
                          is Float) {
                        snapshot.data![position]["friendliness"]
                            .roundToDouble();
                      } else {
                        snapshot.data![position]["friendliness"] = "N/A";
                      }
                      return Card(
                          child: restaurantDesc(
                              snapshot.data![position]["name"],
                              snapshot.data![position]["type"],
                              snapshot.data![position]["friendliness"],
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
                var end = true;
                if (snapshot.data![0] != 'no results') {
                  for (var i = 0; i < snapshot.data!.length; i++) {
                    if (snapshot.data!.length < 8) {
                      end = false;
                    }
                  }
                }
                return ElevatedButton(
                    onPressed: end
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
