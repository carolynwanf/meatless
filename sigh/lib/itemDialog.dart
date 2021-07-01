// import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'reviewForm.dart';

import 'restaurantPage.dart';

class ItemDialog extends StatefulWidget {
  var pins;
  var item;
  ItemDialog({this.pins, this.item});
  _ItemDialogState createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  Widget build(BuildContext context) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
            horizontal: (MediaQuery.of(context).size.width) / 4,
            vertical: (MediaQuery.of(context).size.height) / 20),
        // backgroundColor: Colors.transparent,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                IconButton(
                  icon: pinned ? Icon(Icons.star) : Icon(Icons.star_border),
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
                          for (var i = 0; i < temp['items'].length; i++) {
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
                ),
              ],
            )),
            SliverToBoxAdapter(
                child: Text('${widget.item['name']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height / 30))),
            if (description != 'none')
              SliverToBoxAdapter(child: Text('$description')),
            SliverToBoxAdapter(
                child: InkWell(
                    child: Text('$price • $restaurant'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                RestaurantPage(info: info, pins: widget.pins)),
                      );
                    })),
            if (image != 'none')
              SliverToBoxAdapter(
                  child: Container(
                height: MediaQuery.of(context).size.height / 2,
                child: Image.network(image),
              )),
            SliverToBoxAdapter(child: ReviewForm(id: id))
          ],
        ));
  }
}
