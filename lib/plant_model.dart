import 'dart:convert';

class Plant {
  final int plantId;
  final int? classId; // Make classId optional to support plants without it
  final String name;
  final String? commonName;
  final String? scientificName;
  final String? family;
  final String? medicinalBenefits;
  final String? nutritionalBenefits;
  final List<dynamic>? nutritionalValues;
  final String imageUrl; // แปลง path เป็น URL เต็ม

  Plant({
    required this.plantId,
    this.classId,
    required this.name,
    this.commonName,
    this.scientificName,
    this.family,
    this.medicinalBenefits,
    this.nutritionalBenefits,
    this.nutritionalValues,
    required this.imageUrl,
  });

  // --- CHANGE 2: เพิ่ม helper function สำหรับ parse ---
  // Helper นี้จะรองรับข้อมูลที่เป็น String (ต้อง jsonDecode)
  // หรือข้อมูลที่เป็น List อยู่แล้ว
  static List<dynamic>? _parseNutritionalValues(dynamic rawData) {
    if (rawData == null) {
      return null;
    }
    
    // กรณีที่ 1: ข้อมูลเป็น String (เช่น '[{...}, {...}]')
    if (rawData is String && rawData.isNotEmpty) {
      try {
        return jsonDecode(rawData) as List<dynamic>;
      } catch (e) {
        // ignore: avoid_print
        print('Error decoding nutritional_values string: $e');
        return null; // คืนค่า null ถ้า String ไม่ใช่ JSON ที่ถูกต้อง
      }
    }
    
    // กรณีที่ 2: ข้อมูลเป็น List อยู่แล้ว (API อาจแปลงมาให้)
    if (rawData is List) {
      return rawData;
    }
    
    // กรณีอื่นๆ ที่ไม่รองรับ
    return null;
  }

  // Factory constructor สำหรับสร้าง instance จาก JSON
  factory Plant.fromJson(Map<String, dynamic> json, String baseUrl) {
  // แปลง path ที่ได้จาก API (เช่น ../src/images/horapa.jpg or ..\src\images\kheenhu.jpg)
  // - แปลง backslashes เป็น forward slashes
  // - เอา prefix แบบ ../src/ หรือ ./src/ หรือ src/ หรือ /src/ ออก
  final String rawPath = (json['image_leaf_path'] as String? ?? '');
  final String normalized = rawPath.replaceAll('\\', '/');
  final String imagePath = normalized.replaceFirst(RegExp(r'^(?:\.\./src/|\./src/|/src/|src/)+'), '');
    // Validate numeric ids - ensure plantId is non-null, but classId can be null
    // Check multiple possible field names for plant_id
    dynamic plantIdRaw = json['plant_id'] ?? json['id'] ?? json['plantId'];
    final dynamic classIdRaw = json['class_id'];
    
    // If plant_id is still missing, use a hash of the name as fallback
    // This allows plants without class_id to still be displayed
    int plantId;
    if (plantIdRaw == null) {
      // Generate a stable ID from the plant name hash
      final String plantName = json['name']?.toString() ?? 'Unknown';
      plantId = plantName.hashCode.abs(); // Use absolute value to ensure positive
      // ignore: avoid_print
      print('Warning: Missing plant_id for plant "$plantName", using hash: $plantId');
    } else {
      try {
        plantId = (plantIdRaw is int) ? plantIdRaw : int.parse(plantIdRaw.toString());
      } catch (e) {
        // If parsing fails, use name hash as fallback
        final String plantName = json['name']?.toString() ?? 'Unknown';
        plantId = plantName.hashCode.abs();
        // ignore: avoid_print
        print('Warning: Invalid plant_id format for plant "$plantName", using hash: $plantId');
      }
    }

    int? classId;
    // classId is optional - only parse if it exists
    if (classIdRaw != null) {
      try {
        classId = (classIdRaw is int) ? classIdRaw : int.parse(classIdRaw.toString());
      } catch (e) {
        // ignore: avoid_print
        print('Warning: Invalid class_id format, skipping: $classIdRaw');
      }
    }

    return Plant(
      plantId: plantId,
      classId: classId,
      name: json['name'] ?? 'Unknown',
      commonName: json['common_name'],
      scientificName: json['scientific_name'],
      family: json['family'],
      medicinalBenefits: json['medicinal_benefits'],
      nutritionalBenefits: json['nutritional_benefits'],
      nutritionalValues: _parseNutritionalValues(json['nutritional_value']),
      imageUrl: '$baseUrl/$imagePath',
    );
  }
}