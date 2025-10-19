import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'suggestion.dart';

class AnalysisResultPage extends StatefulWidget {
  final String userId;
  final String? imagePath; // รูปจากหน้าก่อน (ถ่าย/อัปโหลด)
  final String? predictedLabel; // label จาก AI
  final double? confidence; // ความมั่นใจ (0..1)

  const AnalysisResultPage({
    super.key,
    required this.userId,
    this.imagePath,
    this.predictedLabel,
    this.confidence,
  });

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  // === ตั้งค่า API ของฝั่งข้อมูลพืช ===
  // ตัวอย่าง: GET /api/plant?label=แมงลัก
  static const String _apiBase = 'http://localhost:5001';
  static const String _endpoint = '/api/plant';

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _plant; // เก็บรายละเอียดพืชจาก API

  @override
  void initState() {
    super.initState();
    _loadPlantDetail();
  }

  Future<void> _loadPlantDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ถ้าไม่มี predictedLabel ให้หยุดและแสดงข้อความ
      final label = widget.predictedLabel;
      if (label == null || label.trim().isEmpty) {
        throw Exception(
            'ไม่มีชื่อพืชจากผลวิเคราะห์ (predictedLabel) สำหรับดึงข้อมูลรายละเอียด');
      }

      final uri = Uri.parse('$_apiBase$_endpoint').replace(queryParameters: {
        'label': label,
      });

      final resp = await http.get(uri).timeout(const Duration(seconds: 20));

      if (resp.statusCode != 200) {
        throw Exception(
            'โหลดข้อมูลพืชไม่สำเร็จ: ${resp.statusCode} ${resp.body}');
      }

      final data = jsonDecode(resp.body);
      // ====== ตัวอย่าง JSON ที่คาดหวังจากแบ็กเอนด์ ======
      // {
      //   "name_th": "แมงลัก",
      //   "name_en": "Hoary basil",
      //   "sci_name": "Ocimum × africanum",
      //   "family": "Lamiaceae",
      //   "medicinal": "ข้อความ…",
      //   "culinary": "ข้อความ…",
      //   "nutrition": "ข้อความ…",
      //   "image_url": "http://.../manglak.jpg"   // (ถ้าอยากใช้รูปจากเซิร์ฟเวอร์)
      // }

      if (data == null || data is! Map) {
        throw Exception('รูปแบบข้อมูลไม่ถูกต้อง');
      }

      setState(() {
        _plant = Map<String, dynamic>.from(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE9F6EA),
      padding: const EdgeInsets.all(12),
      alignment: Alignment.topLeft,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back,
          color: Color.fromARGB(255, 11, 105, 30),
          size: 48,
        ),
      ),
    );
  }

  Widget _buildImage() {
    // ถ้ามี imagePath จากผู้ใช้ ให้แสดงรูปนั้นก่อน
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      final f = File(widget.imagePath!);
      return Image.file(
        f,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }

    // ถ้าอยากใช้รูปจากแบ็กเอนด์ (image_url) ให้เปิดคอมเมนต์นี้
    // if (_plant?['image_url'] != null) {
    //   return Image.network(
    //     _plant!['image_url'],
    //     width: double.infinity,
    //     fit: BoxFit.cover,
    //     errorBuilder: (_, __, ___) => _fallbackImage(),
    //   );
    // }

    // ถ้าไม่มีก็ใช้ asset เดิมเป็น fallback
    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Image.asset(
      'assets/images/manglug.jpg', // แก้ path ตามโปรเจกต์จริงของคุณ
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Expanded(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Text(
                'เกิดข้อผิดพลาดในการโหลดข้อมูลพืช:\n$_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadPlantDetail,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    final nameTh =
        (_plant?['name_th'] ?? widget.predictedLabel ?? '-').toString();
    final nameEn = (_plant?['name_en'] ?? '—').toString();
    final sci = (_plant?['sci_name'] ?? '—').toString();
    final family = (_plant?['family'] ?? '—').toString();
    final medicinal = (_plant?['medicinal'] ?? '—').toString();
    final culinary = (_plant?['culinary'] ?? '—').toString();
    final nutrition = (_plant?['nutrition'] ?? '—').toString();

    final confText = widget.confidence != null
        ? ' (${(widget.confidence! * 100).toStringAsFixed(1)}%)'
        : '';

    return Expanded(
      child: Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'จากการวิเคราะห์ของเรา',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              // ชื่อพืช (ไทย) + ความมั่นใจ (ถ้ามี)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('พืชชนิดนี้ มีชื่อว่า: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Flexible(
                    child: Text(
                      nameTh + confText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('ชื่อสามัญ: $nameEn'),
              const SizedBox(height: 8),
              Text('ชื่อวิทยาศาสตร์: $sci'),
              const SizedBox(height: 8),
              Text('อยู่ในวงศ์: $family'),
              const SizedBox(height: 16),
              const Text('ประโยชน์ทางยา',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(medicinal),
              const SizedBox(height: 12),
              const Text('ประโยชน์ทางอาหาร',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(culinary),
              const SizedBox(height: 12),
              const Text('คุณค่าทางอาหาร',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(nutrition),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuggestionPage(userId: widget.userId),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color.fromARGB(255, 11, 105, 30)),
          ),
          child: const Center(
            child: Text(
              'ส่งข้อเสนอแนะเพิ่มเติม',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 107, 159, 108),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // โครงสร้างตามของเดิม แต่เป็นไดนามิก + โหลดข้อมูล
    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(context),
          _buildImage(),
          _buildBody(),
          _buildSuggestButton(context),
        ],
      ),
    );
  }
}
