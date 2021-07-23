import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sigh/appColors.dart';
import 'dart:convert';
import 'appColors.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class ContainsMeat extends StatefulWidget {
  final pins;
  final item;
  ContainsMeat({this.pins, this.item});
  _ContainsMeatState createState() => _ContainsMeatState();
}

class _ContainsMeatState extends State<ContainsMeat> {
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
  var nameController = TextEditingController(),
      emailController = TextEditingController();

  var report = {
        'problem': [],
        'name': '',
        'email': '',
      },
      problem = [];
  bool nameProblem = false,
      descProblem = false,
      imageProblem = false,
      requirementsProblem = false,
      orderedProblem = false;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.primary;
    }
    return AppColors.darkGrey;
  }

  Widget customCheckBox(boxValue, kind) {
    return Row(children: [
      Checkbox(
          hoverColor: AppColors.noHover,
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: boxValue,
          onChanged: (bool? value) {
            setState(() {
              if (kind == 'name') {
                nameProblem = value!;
              } else if (kind == 'description') {
                descProblem = value!;
              } else if (kind == 'requirements') {
                requirementsProblem = value!;
              } else if (kind == 'image') {
                imageProblem = value!;
              } else {
                orderedProblem = value!;
              }
              if (value == false) {
                problem.removeAt(problem.indexOf(kind));
              } else {
                problem.add(kind);
              }

              debugPrint('$problem');
            });
          }),
      Text('$kind')
    ]);
  }

  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var dialogWidth = (width < 619 ? width : 619).toDouble();
    var height = MediaQuery.of(context).size.height;
    var dialogHeight = (height < 849 ? height : 849).toDouble();

    var name = widget.item['name'];

    debugPrint('$problem');

    void onContainsMeatSubmitted() async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        var body = {'report': report, "id": widget.item['_id']};

        final response =
            // await http.post(Uri.parse('http://localhost:4000/report'),
            //     headers: {
            //       'Accept': 'application/json',
            //       'Content-Type': 'application/json',
            //     },
            //     body: jsonEncode(body));
            await http.post(Uri.parse('http://10.0.2.2:4000/report'),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode(body));

        debugPrint('$response');

        if (response.statusCode == 200) {
          nameController.clear();
          emailController.clear();
          setState(() {
            nameProblem = false;

            descProblem = false;

            requirementsProblem = false;

            imageProblem = false;

            orderedProblem = false;
          });
          _showToast("Submitted");
        } else {
          _showToast("Error");
        }
      }
    }

    return Dialog(
        insetPadding: dialogWidth < 619 ? EdgeInsets.all(0) : null,
        backgroundColor: Colors.transparent,
        child: Card(
            shape: dialogWidth < 619
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)))
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
            child: Container(
                padding: EdgeInsets.all(10),
                width: dialogWidth,
                height: dialogHeight,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                        // top row with x and star
                        child: Container(
                            width: dialogWidth - 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // close
                                IconButton(
                                  icon: Icon(Icons.close,
                                      color: AppColors.darkGrey),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ))),
                    SliverToBoxAdapter(
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Form(
                              key: _formKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$name contains meat',
                                      style: AppStyles.title,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                        'We’re so sorry that this dish contains meat! How did you know that there was meat in this dish?*',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    FormField(
                                        validator: (value) {
                                          if (problem.length == 0) {
                                            return 'Please check at least one box';
                                          }
                                        },
                                        onSaved: (value) {
                                          debugPrint('$value value');
                                          report['problem'] = problem;
                                        },
                                        initialValue: problem,
                                        builder: (FormFieldState<List> state) {
                                          return Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 15),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    customCheckBox(
                                                        nameProblem, 'name'),
                                                    customCheckBox(descProblem,
                                                        'description'),
                                                    if (widget.item[
                                                            'requirements'] !=
                                                        'none')
                                                      customCheckBox(
                                                          requirementsProblem,
                                                          'requirements'),
                                                    customCheckBox(
                                                        imageProblem, 'image'),
                                                    customCheckBox(
                                                        orderedProblem,
                                                        'I ordered it'),
                                                  ]));
                                        }),
                                    Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Container(
                                            width: dialogWidth / 3,
                                            child: TextFormField(
                                                controller: nameController,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please leave a name';
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 1,
                                                            left: 10),
                                                    focusedBorder: AppStyles
                                                        .focusedInputBorder,
                                                    enabledBorder: AppStyles
                                                        .enabledInputBorder,
                                                    hintText: 'Name*'),
                                                onSaved: (value) {
                                                  report['name'] = value!;
                                                }))),
                                    Container(
                                        width: dialogWidth / 2,
                                        child: TextFormField(
                                          controller: emailController,
                                          validator: (value) {
                                            RegExp validate = RegExp(
                                                r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
                                            var isValid;
                                            if (value is String) {
                                              var temp =
                                                  validate.stringMatch(value);
                                              if (temp == null) {
                                                isValid = false;
                                              } else {
                                                isValid = true;
                                              }
                                            }

                                            debugPrint('isValid: $isValid');
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please leave your email';
                                            } else if (!isValid) {
                                              return 'Please enter a valid email';
                                            }
                                          },
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  bottom: 1, left: 10),
                                              focusedBorder:
                                                  AppStyles.focusedInputBorder,
                                              enabledBorder:
                                                  AppStyles.enabledInputBorder,
                                              hintText: 'Email*'),
                                          onSaved: (value) {
                                            report['email'] = value!;
                                          },
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: AppColors.primary),
                                        onPressed: () {
                                          onContainsMeatSubmitted();
                                        },
                                        child: Text('Submit'),
                                      ),
                                    ),
                                  ]))),
                    )
                  ],
                ))));
  }
}
