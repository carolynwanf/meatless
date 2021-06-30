import 'dart:convert';
import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewForm extends StatefulWidget {
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  // used to uniquely identify form. enables validation
  final _formKey = GlobalKey<FormState>();

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
          TextFormField(
            decoration: InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Enter your review here'),
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please leave a name';
              }
            },
            decoration: InputDecoration(
                border: UnderlineInputBorder(), hintText: 'Name'),
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please leave your email';
              }
            },
            decoration: InputDecoration(
                border: UnderlineInputBorder(), hintText: 'Email'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
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
