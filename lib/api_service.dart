import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'plant_model.dart';

class ApiService {

  static const String _baseUrl = "http://192.168.1.33:3001";
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

  // 3. ดึงข้อมูลรายละเอียดของพืช
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

  // 3b. ดึงข้อมูลรายละเอียดของพืชโดย plantId
  static Future<Plant> getPlantDetailsById(int plantId) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/read/$plantId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['msg'] == 'Read successfully') {
          // ใช้ baseUrl เพื่อสร้าง URL ของรูปภาพให้สมบูรณ์
          return Plant.fromJson(data['plant'], _baseUrl);
        } else {
          throw Exception('API returned an error');
        }
      } else {
        throw Exception('Failed to load plant details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching plant details: $e');
    }
  }

  // 4. ดึงข้อมูลพืชทั้งหมดสำหรับหน้า Library
  static Future<List<Plant>> getAllPlants() async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/read'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic>? plantJson = (data is Map && data['plant'] is List) ? List<dynamic>.from(data['plant']) : null;
        if (plantJson == null) {
          throw Exception('Unexpected API response shape: ${response.body}');
        }

        final List<Plant> plants = [];
        for (final item in plantJson) {
          try {
            // attempt to parse and construct Plant; this may throw a FormatException
            plants.add(Plant.fromJson(item as Map<String, dynamic>, _baseUrl));
          } catch (e) {
            // Log and skip malformed rows instead of crashing the whole fetch
            // ignore: avoid_print
            print('Skipping invalid plant entry: $e -- raw: $item');
          }
        }

        return plants;
      } else {
        throw Exception('Failed to load plants: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching all plants: $e');
    }
  }

  // 5. ส่งข้อเสนอแนะ
  static Future<void> submitSuggestion({required int userId, required String message}) async {
    try {
       final response = await http.post(
        Uri.parse('$_apiUrl/suggestions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId, 
          'message': message,
        }),
       );
       if(response.statusCode != 200) {
          throw Exception('Failed to submit suggestion: ${response.body}');
       }
    } catch (e) {
       throw Exception('Error submitting suggestion: $e');
    }
  }
}