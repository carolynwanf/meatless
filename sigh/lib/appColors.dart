import 'package:flutter/material.dart';

class AppColors {
  static var primary = Colors.teal.shade400;
  static var primaryDark = Colors.teal.shade500;
  static var darkText = Colors.teal.shade900;
  static var lightestGrey = Colors.grey.shade200;
  static var lightGrey = Colors.grey.shade300;
  static var medGrey = Colors.grey.shade400;
  static var darkGrey = Colors.grey.shade600;
  static var accent = Colors.orange.shade800;
  static var accentLight = Color(0xAAEC833B);
  static var star = Colors.yellow.shade700;
  static var noHover = Colors.white.withOpacity(0);
}

// class LocalStorage {
//   Future<String> get _localPath async {
//     final directory = await getApplicationDocumentsDirectory();

//     return directory.path;
//   }

//   Future<File> get _localFile async {
//     final path = await _localPath;
//     return File('$path/pins.json');
//   }

//   Future<Object> readPins() async {
//     try {
//       final file = await _localFile;

//       // Read the file
//       final contents = await file.readAsString();

//       return jsonDecode(contents);
//     } catch (e) {
//       // If encountering an error, return 0
//       return e;
//     }
//   }

//   Future<File> writePins(pins) async {
//     debugPrint('$pins, write');
//     final file = await _localFile;
//     final write = jsonEncode(pins);
//     debugPrint('$write, encoded');
//     // Write the file
//     return file.writeAsString(write);
//   }

//   Future<File> initiatePins() async {
//     final file = await _localFile;
//     final write = jsonEncode({'ids': <String>{}, 'items': [], 'display': true});

//     // Write the file
//     return file.writeAsString(write);
//   }
// }

class AppStyles {
  static var header = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
  static var headerMobile =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w600);
  static var subtitle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade600,
      height: 1.2,
      letterSpacing: 0.3);
  static var subtitleMobile = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade600,
      height: 1.2,
      letterSpacing: 0.3);
  static var title = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      height: 1.2,
      letterSpacing: 0.3);
  static var bigTitle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      height: 1.2,
      letterSpacing: 0.3);
  static var detail = TextStyle(fontSize: 13, height: 1.2, letterSpacing: 0.3);
  static var detailMobile =
      TextStyle(fontSize: 15, height: 1.2, letterSpacing: 0.3);
  static var focusedInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
    borderSide: BorderSide(color: AppColors.darkGrey, width: 1.5),
  );
  static var enabledInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(5),
    ),
    borderSide: BorderSide(color: AppColors.medGrey, width: 1),
  );
  static var hintText = TextStyle(fontSize: 14);
}
