import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../constants.dart';

class ProfileApi {
  // Upload resume using multipart
  static Future<Map<String, dynamic>?> uploadResume(String email, PlatformFile file) async {
    final uri = Uri.parse('$backendBase/upload_resume'); // fixed interpolation
    final request = http.MultipartRequest('POST', uri);
    request.fields['email'] = email;
    request.files.add(
      http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
    );

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200) return json.decode(resp.body);
    return null;
  }

  // Submit typed experience
  static Future<Map<String, dynamic>?> typeExperience(String email, String experience) async {
    final uri = Uri.parse('$backendBase/type_experience'); // fixed interpolation
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'}, // ensure backend receives JSON
      body: jsonEncode({'email': email, 'experience': experience}),
    );
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  // Fetch matches for a profile
  static Future<List> getMatches(int profileId, {double threshold = 0.7}) async {
    final uri = Uri.parse('$backendBase/profiles/$profileId/matches?threshold=$threshold'); // fixed interpolation
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['matches'] as List;
    }
    return [];
  }
}
