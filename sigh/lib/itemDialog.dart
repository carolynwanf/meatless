// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sigh/appColors.dart';
// import 'package:http/http.dart' as http;
import 'reviewForm.dart';

import 'restaurantPage.dart';
import 'containsMeat.dart';

class ItemDialog extends StatefulWidget {
  var pins;
  var item;
  ItemDialog({this.pins, this.item});
  _ItemDialogState createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var dialogWidth = (width < 619 ? width : 619).toDouble();
    var height = MediaQuery.of(context).size.height;
    var dialogHeight = (height < 849 ? height : 849).toDouble();
    var item = widget.item,
        id = item['_id'],
        image = item['images'],
        description = item['description'],
        price = item['price'],
        restaurant = item['restuarant_name'],
        restaurantId = item['restaurant_id'];

    var info = {
      'name': restaurant,
      "id": restaurantId,
    };
    if (image != 'none') {
      image = image.split(" 1920w,");
      image = image[0];

      image = image.split(
          'https://img.cdn4dd.com/cdn-cgi/image/fit=contain,width=1920,format=auto,quality=50/');

      image = image[1];
    }
    var pinned = item['pinned'];
    return Dialog(
        insetPadding: dialogWidth < 619 ? EdgeInsets.all(0) : null,
        backgroundColor: Colors.transparent,
        // backgroundColor: Colors.transparent,
        child: Card(
            shape: dialogWidth < 619
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)))
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
            child: Container(
                width: dialogWidth,
                height: dialogHeight,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                        // top row with x and star
                        child: Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                                // star
                                IconButton(
                                  icon: pinned
                                      ? Icon(Icons.star, color: AppColors.star)
                                      : Icon(Icons.star_border,
                                          color: AppColors.darkGrey),
                                  onPressed: !pinned
                                      ? () {
                                          debugPrint('pressed');
                                          var temp = widget.pins;

                                          temp['ids'].add(id);
                                          temp['items'].add(item);
                                          debugPrint('$temp');

                                          setState(() {
                                            widget.pins = temp;
                                            item['pinned'] = true;
                                          });
                                        }
                                      : () {
                                          debugPrint('pressed');
                                          var temp = widget.pins;
                                          debugPrint('$temp');
                                          temp['ids'].remove(id);
                                          for (var i = 0;
                                              i < temp['items'].length;
                                              i++) {
                                            if (temp['items'][i]['_id'] == id) {
                                              temp['items'].removeAt(i);
                                              break;
                                            }
                                          }
                                          setState(() {
                                            debugPrint('setting state');
                                            widget.pins = temp;
                                            item['pinned'] = false;
                                          });
                                        },
                                )
                              ],
                            ))),
                    // info at top
                    SliverToBoxAdapter(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                // name of dish
                                Container(
                                    width: dialogWidth,
                                    child: Text(
                                      '${widget.item['name']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              30),
                                      textAlign: TextAlign.left,
                                    )),
                                // description of dish, if it exists
                                if (description != 'none')
                                  Container(
                                      width: dialogWidth,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text('$description',
                                          textAlign: TextAlign.left,
                                          style: AppStyles.subtitle)),
                                // price + restaurant of dish
                                Container(
                                    width: dialogWidth,
                                    child: InkWell(
                                        child: Text('$price • $restaurant'),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => RestaurantPage(
                                                    info: info,
                                                    pins: widget.pins)),
                                          );
                                        }))
                              ],
                            ))),

                    if (image != 'none')
                      SliverToBoxAdapter(
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              width: dialogWidth - 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(image,
                                    fit: BoxFit.fitWidth,
                                    width: dialogWidth - 40),
                              ))),
                    SliverToBoxAdapter(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: ReviewForm(id: id))),
                    SliverToBoxAdapter(
                        child: InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ContainsMeat(
                                        pins: widget.pins, item: item);
                                  });
                            },
                            hoverColor: AppColors.noHover,
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: Column(children: [
                                  Container(
                                      width: dialogWidth - 40,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                          'Does this dish contain meat?',
                                          style: AppStyles.header)),
                                  Container(
                                      padding: EdgeInsets.only(bottom: 20),
                                      width: dialogWidth - 40,
                                      alignment: Alignment.centerLeft,
                                      child: Text('Click here to report',
                                          style: AppStyles.subtitle))
                                ]))))
                  ],
                ))));
  }
}
