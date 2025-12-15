// api/jobs_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class JobsApi {
  static const String backendBase = "http://127.0.0.1:8000"; // your FastAPI URL

  static Future<List<Map<String, dynamic>>> searchJobs(String role) async {
    final uri = Uri.parse("$backendBase/search_jobs?role=${Uri.encodeComponent(role)}");
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data['jobs'] ?? []);
    } else {
      return [];
    }
  }
}
