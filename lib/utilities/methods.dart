import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class AppMethods {
  // Create Material Color
  static MaterialColor createMaterialColor(Color color) {
    List<int> strengths = <int>[
      50,
      100,
      200,
      300,
      400,
      500,
      600,
      700,
      800,
      900
    ];
    // Create swatch
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int strength in strengths) {
      final double ds = 0.5 - ((strength / 1000) / 2);
      swatch[strength] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  // Compress file
  static Future<File> compressFilePNG(File file) async {
    // Generate unique id
    var uniqueId = const Uuid().v4();
    // Get the temporary directory
    final dir = await path_provider.getTemporaryDirectory();
    // Create the final path
    final targetPath = "${dir.absolute.path}/$uniqueId.png";
    // Compress the file
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 10,
      format: CompressFormat.png,
    );

    return File(result!.path);
  }
}
