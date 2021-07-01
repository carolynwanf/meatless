// import 'dart:convert';
// import 'dart:html';
// import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class ReviewForm extends StatefulWidget {
  var id;

  ReviewForm({this.id});
  _ReviewFormState createState() => _ReviewFormState();
}

// Future<List> sendReview(review) async {
//   final String body = jsonEncode({"offset": offset});
//   final response =
//       await http.post(Uri.parse('http://localhost:4000/get-dishes'),
//           headers: {
//             'Accept': 'application/json',
//             'Content-Type': 'application/json',
//           },
//           body: body);

//   // if (response.body.length > 100) {
//   return jsonDecode(response.body)['dishes'];
//   // }
// }

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  var numberOfStars = 0;

  var review = {'rating': 0, 'review': null, 'name': '', 'email': ''};

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            child: Text(
              "Leave a rating/review",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            alignment: Alignment.bottomLeft,
          ),
          FormField(
            initialValue: numberOfStars,
            builder: (FormFieldState<int> state) {
              return Row(
                children: [
                  InkWell(
                      onTap: () {
                        state.didChange(1);
                        setState(() {
                          numberOfStars = 1;
                        });
                      },
                      child: numberOfStars > 0
                          ? Icon(Icons.star)
                          : Icon(Icons.star_border)),
                  InkWell(
                      onTap: () {
                        state.didChange(2);
                        setState(() {
                          numberOfStars = 2;
                        });
                      },
                      child: numberOfStars > 1
                          ? Icon(Icons.star)
                          : Icon(Icons.star_border)),
                  InkWell(
                      onTap: () {
                        state.didChange(3);
                        setState(() {
                          numberOfStars = 3;
                        });
                      },
                      child: numberOfStars > 2
                          ? Icon(Icons.star)
                          : Icon(Icons.star_border)),
                  InkWell(
                      onTap: () {
                        state.didChange(4);
                        setState(() {
                          numberOfStars = 4;
                        });
                      },
                      child: numberOfStars > 3
                          ? Icon(Icons.star)
                          : Icon(Icons.star_border)),
                  InkWell(
                      onTap: () {
                        state.didChange(5);
                        setState(() {
                          numberOfStars = 5;
                        });
                      },
                      child: numberOfStars > 4
                          ? Icon(Icons.star)
                          : Icon(Icons.star_border)),
                ],
              );
            },
            validator: (value) {
              if (value == 0) {
                debugPrint('stars $value');
                return "Please rate this dish";
              }
            },
            onSaved: (value) {
              review['rating'] = value;
            },
          ),
          TextFormField(
              decoration: InputDecoration(
                  border: UnderlineInputBorder(), hintText: 'review'),
              onSaved: (value) {
                if (value == '') {
                  review['review'] = null;
                } else {
                  review['review'] = value;
                }
              }),
          TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please leave a name';
                }
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(), hintText: 'Name'),
              onSaved: (value) {
                review['name'] = value;
              }),
          TextFormField(
              validator: (value) {
                RegExp validate = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
                var isValid;
                if (value is String) {
                  var temp = validate.stringMatch(value);
                  if (temp == null) {
                    isValid = false;
                  } else {
                    isValid = true;
                  }
                }

                debugPrint('isValid: $isValid');
                if (value == null || value.isEmpty) {
                  return 'Please leave your email';
                } else if (!isValid) {
                  return 'Please enter a valid email';
                }
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(), hintText: 'Email'),
              onSaved: (value) {
                review['email'] = value;
              }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  debugPrint('review: $review');

                  final body = {
                    'review': review,
                    'id': widget.id,
                  };

                  final response = await http.post(
                      Uri.parse('http://localhost:4000/review-or-rating'),
                      headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode(body));

                  debugPrint('${response}');
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Submitting')));
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
