import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sigh/appColors.dart';
import 'appColors.dart';

class ContainsMeat extends StatefulWidget {
  var pins;
  var item;
  ContainsMeat({this.pins, this.item});
  _ContainsMeatState createState() => _ContainsMeatState();
}

class _ContainsMeatState extends State<ContainsMeat> {
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    var width = MediaQuery.of(context).size.width;
    var dialogWidth = (width < 619 ? width : 619).toDouble();
    var height = MediaQuery.of(context).size.height;
    var dialogHeight = (height < 849 ? height : 849).toDouble();

    var name = widget.item['name'];

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
                            child: Column(children: [
                              Text('$name contains meat',
                                  style: AppStyles.title),
                              Container(
                                  child: Text(
                                      'We’re so sorry that this dish contains meat! Please let us know what part of the dish tipped you off to this fact.',
                                      style: TextStyle(fontSize: 15)),
                                  padding: EdgeInsets.symmetric(vertical: 10))
                            ]))),
                    // SliverToBoxAdapter(child: Form(key: _formKey,))
                  ],
                ))));
  }
}
