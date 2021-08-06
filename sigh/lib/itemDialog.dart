// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sigh/appColors.dart';
// import 'package:http/http.dart' as http;
import 'reviewForm.dart';

import 'restaurantPage.dart';
import 'containsMeat.dart';

class ItemDialog extends StatefulWidget {
  final pins;
  final item;

  ItemDialog({this.pins, this.item});
  _ItemDialogState createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  var pins;
  Widget build(BuildContext context) {
    pins = widget.pins;
    var width = MediaQuery.of(context).size.width;
    var dialogWidth = (width < 619 ? width : 619).toDouble();
    var height = MediaQuery.of(context).size.height;
    var dialogHeight = (height < 1000 ? height : 800).toDouble();
    var item = widget.item,
        id = item['_id'],
        image = item['images'],
        description = item['description'],
        price = item['price'],
        restaurant = item['restuarant_name'],
        restaurantId = item['restaurant_id'],
        requirements = item['requirements'];

    var display = '';

    if (description != 'none') {
      if (description[description.length - 1] == '.') {
        display = '$description';
      } else {
        display = '$description.';
      }
    }

    if (requirements != 'none') {
      display = '$display $requirements';
    }

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
    var pinned = pins['ids'].contains(id);

    navigateToRestaurantPage(name) {
      var words = name.split(' ');
      var noSpaces = words[0];
      for (var i = 1; i < words.length; i++) {
        noSpaces = '$noSpaces-${words[i]}';
      }

      Navigator.pushNamed(context, '/restaurant/$noSpaces',
              arguments: {'info': info, 'pins': pins})
          .then((val) => {setState(() {})});
    }

    return Dialog(
        insetPadding: dialogWidth < 619
            ? EdgeInsets.all(0)
            : EdgeInsets.symmetric(vertical: 20),
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
                                          var temp = pins;

                                          temp['ids'].add(id);
                                          temp['items'].add(item);
                                          debugPrint('$temp');

                                          setState(() {
                                            pins = temp;
                                            item['pinned'] = true;
                                          });
                                        }
                                      : () {
                                          debugPrint('pressed');
                                          var temp = pins;
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
                                            pins = temp;
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
                                      style: AppStyles.title,
                                      textAlign: TextAlign.left,
                                    )),
                                // description of dish, if it exists
                                if (display != '')
                                  Container(
                                      width: dialogWidth,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text('$display',
                                          textAlign: TextAlign.left,
                                          style: dialogWidth > 619
                                              ? AppStyles.subtitle
                                              : AppStyles.subtitleMobile)),
                                // price + restaurant of dish
                                Container(
                                    width: dialogWidth,
                                    child: InkWell(
                                        child: Text('$price • $restaurant',
                                            style: dialogWidth > 619
                                                ? AppStyles.detail
                                                : AppStyles.detailMobile),
                                        onTap: () {
                                          navigateToRestaurantPage(
                                              info['name']);
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
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: ReviewForm(id: id))),
                    SliverToBoxAdapter(
                        child: InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ContainsMeat(pins: pins, item: item);
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
