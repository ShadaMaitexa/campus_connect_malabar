import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = "do6l9elab";
  static const String uploadPreset = "campusconnect_images";

  static Future<String?> upload(File file) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/auto/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);

    return json['secure_url'];
  }
  
}
