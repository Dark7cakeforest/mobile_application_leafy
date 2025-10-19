// lib/models/plant_model.dart

class Plant {
  final int plantId;
  final int classId;
  final String name;
  final String? commonName;
  final String? scientificName;
  final String? family;
  final String? medicinalBenefits;
  final String? nutritionalBenefits;
  final String imageUrl; // เราจะแปลง path เป็น URL เต็ม

  Plant({
    required this.plantId,
    required this.classId,
    required this.name,
    this.commonName,
    this.scientificName,
    this.family,
    this.medicinalBenefits,
    this.nutritionalBenefits,
    required this.imageUrl,
  });

  // Factory constructor สำหรับสร้าง instance จาก JSON
  factory Plant.fromJson(Map<String, dynamic> json, String baseUrl) {
    // แปลง path ที่ได้จาก API (เช่น ../src/images/horapa.jpg) เป็น URL ที่เข้าถึงได้
    String imagePath = (json['image_leaf_path'] as String? ?? '').replaceAll('../src/', '');
    
    return Plant(
      plantId: json['plant_id'],
      classId: json['class_id'],
      name: json['name'],
      commonName: json['common_name'],
      scientificName: json['scientific_name'],
      family: json['family'],
      medicinalBenefits: json['medicinal_benefits'],
      nutritionalBenefits: json['nutritional_benefits'],
      imageUrl: '$baseUrl/$imagePath',
    );
  }
}