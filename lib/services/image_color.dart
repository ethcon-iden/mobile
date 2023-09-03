import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:palette_generator/palette_generator.dart';

const String keyPalette = 'palette';
const String keyNoOfItems = 'noIfItems';

int noOfPixelsPerAxis = 12;

Future<PaletteGenerator> updatePaletteGeneratorFromFile(File input) async {
  final paletteGenerator = await PaletteGenerator.fromImageProvider(
      Image.file(input).image
  );
  return paletteGenerator;
}

Color getAverageColor(List<Color> colors) {
  int r = 0, g = 0, b = 0;

  for (int i = 0; i < colors.length; i++) {
    r += colors[i].red;
    g += colors[i].green;
    b += colors[i].blue;
  }

  r = r ~/ colors.length;
  g = g ~/ colors.length;
  b = b ~/ colors.length;

  return Color.fromRGBO(r, g, b, 1);
}

Color abgrToColor(int argbColor) {
  int r = (argbColor >> 16) & 0xFF;
  int b = argbColor & 0xFF;
  int hex = (argbColor & 0xFF00FF00) | (b << 16) | r;
  print("---> abgrToColor > hex: $hex ");

  return Color(hex);
}

List<Color> sortColors(List<Color> colors) {
  List<Color> sorted = [];

  sorted.addAll(colors);
  sorted.sort((a, b) => b.computeLuminance().compareTo(a.computeLuminance()));

  return sorted;
}

List<Color> generatePalette(Map<String, dynamic> params) {
  List<Color> colors = [];
  List<Color> palette = [];

  colors.addAll(sortColors(params[keyPalette]));

  int noOfItems = params[keyNoOfItems];

  if (noOfItems <= colors.length) {
    int chunkSize = colors.length ~/ noOfItems;

    for (int i = 0; i < noOfItems; i++) {
      palette.add(
          getAverageColor(colors.sublist(i * chunkSize, (i + 1) * chunkSize)));
    }
  }

  return palette;
}

List<Color> extractPixelsColors(Uint8List? bytes) {
  List<Color> colors = [];

  Uint8List values = bytes!.buffer.asUint8List();
  imageLib.Image? image = imageLib.decodeImage(values);

  List<int?> pixels = [];

  int? width = image?.width;
  int? height = image?.height;

  int xChunk = width! ~/ (noOfPixelsPerAxis + 1);
  int yChunk = height! ~/ (noOfPixelsPerAxis + 1);

  for (int j = 1; j < noOfPixelsPerAxis + 1; j++) {
    for (int i = 1; i < noOfPixelsPerAxis + 1; i++) {
      imageLib.Pixel? pixel = image?.getPixel(xChunk * i, yChunk * j);
      print("---> ($j, $i) pixel int: $pixel ");

      final hex = _rgbToHex(pixel!.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
      print("---> ($j, $i) hex: $hex ");

      final color = _hexToColor(hex);
      colors.add(color);
    }
  }

  return colors;
}

String _rgbToHex(int r, int g, int b) {
  return '#${(r << 16 | g << 8 | b).toRadixString(16).padLeft(6, '0')}';
}

Color _hexToColor(String hexColor) {
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}

Color generateRandomColor() {
  Random random = Random();
  int r = random.nextInt(256);
  int g = random.nextInt(256);
  int b = random.nextInt(256);
  return Color.fromRGBO(r, g, b, 1.0);
}

// const ColorFilter greyscale = ColorFilter.matrix(<double>[
//   0.2126, 0.7152, 0.0722, 0, 0,   // Red scale
//   0.2126, 0.7152, 0.0722, 0, 0,   // Red scale
//   0.2126, 0.7152, 0.0722, 0, 0,   // Red scale
//   0,      0,      0,      1, 0,   // Red scale
// ]);

const ColorFilter greyscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0022, 0, 0, // Red scale
  0.2126, 0.7152, 0.0022, 0, 0, // Green scale
  0.2126, 0.7152, 0.0022, 0, 0, // Blue scale
  0,      0,      0.5,      0.3, 0, // Alpha scale
]);