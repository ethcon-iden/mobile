import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageHandler {

  static final ImageHandler _instance = ImageHandler();

  static Future<String?> pickImageFromLocal() async {
    String? path;

    final ImagePicker picker = ImagePicker();

    final XFile? selectedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 200,
      maxWidth: 300,
    );
    if (selectedFile != null) {
      final a = selectedFile.name;
      path = selectedFile.path;
    } else {
      path = null;
    }
    return Future.value(path);
  }

  static Future<String> downloadAndSaveImage(String imageUrl) async {
    String? path;
    try {
      final url = Uri.parse(imageUrl);
      final response = await http.get(url);
      final bytes = response.bodyBytes;

      final String filename = _instance._getFileNameFromUrl(url);

      final appDir = await getApplicationDocumentsDirectory();
      path = '${appDir.path}/$filename';
      final file = File(path);
      await file.writeAsBytes(bytes);

      print('Image saved to: ${file.path}');
    } catch (error) {
      print('---> Error while downloading image: $error');
    }
    return Future.value(path);
  }

  String _getFileNameFromUrl(Uri uri) {
    String out = '';
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      out = pathSegments.last;
    } else {
      '${DateTime.now().millisecondsSinceEpoch}.png';
    }
    return out;
  }

  static Future<String> saveTemporaryPath(Uint8List imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final String tempPath = '${tempDir.path}/temp.png';
    File file  = await File(tempPath).create();
    await file.writeAsBytes(imageFile);
    return Future.value(file.path);
  }

  static Future<bool> captureAndSave2album(GlobalKey globalKey) async {
    bool out;

    final RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();

    ByteData? byteData = await (image.toByteData(format: ui.ImageByteFormat.png));

    // Save the image to the gallery
    if (byteData != null) {
      final result = await ImageGallerySaver.saveImage(
          byteData.buffer.asUint8List(),
          quality: 100
      );
      if (result['isSuccess'] == true) {
        out = true;
      } else {
        out = false;
      }
    } else {
      out = false;
    }
    return out;
  }

  static Future<void> saveImage2album(Uint8List image) async {
    await ImageGallerySaver.saveImage(image);
  }
}