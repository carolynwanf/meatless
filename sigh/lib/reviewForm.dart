// import 'dart:convert';
// import 'dart:html';
// import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'appColors.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:convert';

class ReviewForm extends StatefulWidget {
  final id;

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
  var submittedToast;

  @override
  void initState() {
    super.initState();
    submittedToast = FToast();
    submittedToast.init(context);
  }

  _showToast(text) {
    var color = AppColors.accent;
    if (text == 'Error') {
      color = Colors.red;
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
          if (text == 'Submitted') Icon(Icons.check, color: Colors.white),
          if (text == "Error") Icon(Icons.cancel, color: Colors.white),
          SizedBox(
            width: 12.0,
          ),
          Text("$text",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );

    submittedToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  final _formKey = GlobalKey<FormState>();
  var numberOfStars = 0;
  var nameController = TextEditingController(),
      reviewController = TextEditingController(),
      emailController = TextEditingController();

  var review = {'rating': 0, 'review': null, 'name': '', 'email': ''};

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              "Leave a rating/review",
              style: AppStyles.header,
            ),
            alignment: Alignment.bottomLeft,
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: FormField(
                initialValue: numberOfStars,
                builder: (FormFieldState<int> state) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                          onTap: () {
                            state.didChange(1);
                            setState(() {
                              numberOfStars = 1;
                            });
                          },
                          child: numberOfStars > 0
                              ? Icon(Icons.star, color: AppColors.star)
                              : Icon(Icons.star_border)),
                      GestureDetector(
                          onTap: () {
                            state.didChange(2);
                            setState(() {
                              numberOfStars = 2;
                            });
                          },
                          child: numberOfStars > 1
                              ? Icon(Icons.star, color: AppColors.star)
                              : Icon(Icons.star_border)),
                      GestureDetector(
                          onTap: () {
                            state.didChange(3);
                            setState(() {
                              numberOfStars = 3;
                            });
                          },
                          child: numberOfStars > 2
                              ? Icon(Icons.star, color: AppColors.star)
                              : Icon(Icons.star_border)),
                      GestureDetector(
                          onTap: () {
                            state.didChange(4);
                            setState(() {
                              numberOfStars = 4;
                            });
                          },
                          child: numberOfStars > 3
                              ? Icon(Icons.star, color: AppColors.star)
                              : Icon(Icons.star_border)),
                      GestureDetector(
                          onTap: () {
                            state.didChange(5);
                            setState(() {
                              numberOfStars = 5;
                            });
                          },
                          child: numberOfStars > 4
                              ? Icon(Icons.star, color: AppColors.star)
                              : Icon(Icons.star_border)),
                      Text("*")
                    ],
                  );
                },
                validator: (value) {
                  debugPrint('$value fsldkj');
                  if (value == null || value == 0) {
                    debugPrint('stars $value');
                    return "Please rate this dish";
                  }
                },
                onSaved: (value) {
                  review['rating'] = value;
                },
              )),
          TextFormField(
              controller: reviewController,
              maxLines: 5,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 1, left: 10, top: 15),
                  focusedBorder: AppStyles.focusedInputBorder,
                  enabledBorder: AppStyles.enabledInputBorder,
                  hintText: 'Review'),
              onSaved: (value) {
                if (value == '') {
                  review['review'] = null;
                } else {
                  review['review'] = value;
                }
              }),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                  width: 150,
                  child: TextFormField(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please leave a name';
                        }
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 1, left: 10),
                          focusedBorder: AppStyles.focusedInputBorder,
                          enabledBorder: AppStyles.enabledInputBorder,
                          hintText: 'Name*'),
                      onSaved: (value) {
                        review['name'] = value;
                      }))),
          SizedBox(
              width: 200,
              child: TextFormField(
                  controller: emailController,
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
                      contentPadding: EdgeInsets.only(bottom: 1, left: 10),
                      focusedBorder: AppStyles.focusedInputBorder,
                      enabledBorder: AppStyles.enabledInputBorder,
                      hintText: 'Email*'),
                  onSaved: (value) {
                    review['email'] = value;
                  })),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: AppColors.primary),
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  debugPrint('review: $review');

                  final body = {
                    'review': review,
                    'id': widget.id,
                  };

                  debugPrint('$body');

                  final response = await http.post(
                      Uri.parse('http://localhost:4000/review-or-rating'),
                      headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode(body));

                  if (response.statusCode == 200) {
                    reviewController.clear();
                    emailController.clear();
                    nameController.clear();

                    setState(() {
                      numberOfStars = 0;
                    });
                    _showToast("Submitted");
                  } else {
                    _showToast("Error");
                  }
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
