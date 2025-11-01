import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import '../model/face_analysis_response.dart';

class FaceAuthService {
  static const String _baseUrl = 'http://10.198.125.23:8000';

  Future<void> reset() async {
    final resp = await http.post(Uri.parse('$_baseUrl/api/face/reset'));
    if (resp.statusCode != 200) throw Exception('reset ${resp.statusCode}');
  }

  Future<FaceAnalysisResponse> analyzeFrame(XFile image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/face/analyze'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      throw Exception('analyze ${streamed.statusCode}');
    }

    final body = await streamed.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    return FaceAnalysisResponse.fromJson(json);
  }
}