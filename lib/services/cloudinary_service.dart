import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class CloudinaryService {
  static const String cloudName = "do6l9elab";
  static const String uploadPreset = "campusconnect_images";

  static Future<String?> upload(dynamic file, {String? filename}) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/auto/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset;

    Uint8List bytes;
    if (file is Uint8List) {
      bytes = file;
    } else {
      // Assume it's an XFile or something that has readAsBytes()
      bytes = await (file as dynamic).readAsBytes();
    }

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename ?? 'upload.jpg',
    ));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);

    return json['secure_url'];
  }

  static Future<String> uploadBookImage(dynamic imageFile, {String? filename}) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset;

    Uint8List bytes;
    if (imageFile is Uint8List) {
      bytes = imageFile;
    } else {
      bytes = await (imageFile as dynamic).readAsBytes();
    }

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename ?? 'book_cover.jpg',
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      return data['secure_url'];
    } else {
      throw Exception("Cloudinary upload failed");
    }
  }
}
