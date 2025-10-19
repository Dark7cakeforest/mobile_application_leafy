// lib/api_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ***สำคัญ: แก้ไข IP Address ให้เป็นของเครื่องคอมพิวเตอร์ของคุณ***
  static const String _baseUrl = "http://127.0.0.1:3001/api";

  // 1. ส่งรูปภาพไปประมวลผล
  static Future<Map<String, dynamic>> predictImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/predict'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        final errorData = await response.stream.bytesToString();
        throw Exception('Failed to predict: ${response.statusCode} - $errorData');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // 2. ส่ง Feedback (ถูก/ผิด)
  static Future<void> sendFeedback(int resultId, bool isCorrect) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/mobile_feedback/$resultId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'is_correct': isCorrect ? 1 : 0}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send feedback: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending feedback: $e');
    }
  }

  // 3. ดึงข้อมูลรายละเอียดของพืช
  static Future<Map<String, dynamic>> getPlantDetails(int classId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/plant_details/$classId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if(data['success'] == true) {
          return data['details'];
        } else {
          throw Exception('API returned an error: ${data['error']}');
        }
      } else {
        throw Exception('Failed to load plant details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching plant details: $e');
    }
  }
}