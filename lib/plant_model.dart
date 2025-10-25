class Plant {
  final int plantId;
  final int classId;
  final String name;
  final String? commonName;
  final String? scientificName;
  final String? family;
  final String? medicinalBenefits;
  final String? nutritionalBenefits;
  final String imageUrl; // แปลง path เป็น URL เต็ม

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
  // แปลง path ที่ได้จาก API (เช่น ../src/images/horapa.jpg or ..\src\images\kheenhu.jpg)
  // - แปลง backslashes เป็น forward slashes
  // - เอา prefix แบบ ../src/ หรือ ./src/ หรือ src/ หรือ /src/ ออก
  final String rawPath = (json['image_leaf_path'] as String? ?? '');
  final String normalized = rawPath.replaceAll('\\', '/');
  final String imagePath = normalized.replaceFirst(RegExp(r'^(?:\.\./src/|\./src/|/src/|src/)+'), '');
    // Validate numeric ids - ensure they are non-null and int-compatible
    final dynamic plantIdRaw = json['plant_id'];
    final dynamic classIdRaw = json['class_id'];
    if (plantIdRaw == null) {
      throw FormatException('Missing plant_id in JSON: $json');
    }
    if (classIdRaw == null) {
      throw FormatException('Missing class_id in JSON: $json');
    }

    int plantId;
    int classId;
    try {
      plantId = (plantIdRaw is int) ? plantIdRaw : int.parse(plantIdRaw.toString());
      classId = (classIdRaw is int) ? classIdRaw : int.parse(classIdRaw.toString());
    } catch (e) {
      throw FormatException('Invalid numeric id in JSON: plant_id=$plantIdRaw, class_id=$classIdRaw');
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
      imageUrl: '$baseUrl/$imagePath',
    );
  }
}