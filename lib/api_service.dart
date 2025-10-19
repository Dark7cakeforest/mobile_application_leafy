// lib/api_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'plant_model.dart';

class ApiService {
  static const String _baseUrl = "http://192.168.1.100:3001";
  static const String _apiUrl = "$_baseUrl/api";

  // 1. ส่งรูปภาพไปประมวลผล
  static Future<Map<String, dynamic>> predictImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_apiUrl/predict'));
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
        Uri.parse('$_apiUrl/mobile_feedback/$resultId'),
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

  // 3. ดึงข้อมูลรายละเอียดของพืช (ใช้ Plant model)
  static Future<Plant> getPlantDetails(int classId) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/plant_details/$classId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // ใช้ baseUrl เพื่อสร้าง URL ของรูปภาพให้สมบูรณ์
          return Plant.fromJson(data['details'], _baseUrl);
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

  // 4. [ใหม่] ดึงข้อมูลพืชทั้งหมดสำหรับหน้า Library
  static Future<List<Plant>> getAllPlants() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/read'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> plantJson = data['plant'];
        return plantJson.map((json) => Plant.fromJson(json, _baseUrl)).toList();
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (e) {
      throw Exception('Error fetching all plants: $e');
    }
  }

  // 5. [ใหม่] ส่งข้อเสนอแนะ
  static Future<void> submitSuggestion(String message) async {
    // หมายเหตุ: Backend endpoint /api/suggestions ในไฟล์ database.js
    // ที่ให้มาอาจจะต้องปรับแก้เพื่อรองรับ guest user
    try {
       final response = await http.post(
        Uri.parse('$_apiUrl/suggestions'), // Endpoint นี้อาจจะต้องสร้างใน backend
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'message': message}),
       );
       if(response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to submit suggestion: ${response.body}');
       }
    } catch (e) {
       throw Exception('Error submitting suggestion: $e');
    }
  }
}