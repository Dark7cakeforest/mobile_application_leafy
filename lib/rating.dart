import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'analysisresult.dart';

class RatingPage extends StatefulWidget {
  final String userId;

  /// ข้อมูลจาก AI/ResultPage (ถ้ามีจะโชว์บนหัวข้อและรูป)
  final String? predictedLabel; // เช่น "แมงลัก"
  final double? confidence; // 0..1
  final String? imagePath; // path ของภาพที่ถ่าย/อัปโหลด

  const RatingPage({
    super.key,
    this.userId = 'guest',
    this.predictedLabel,
    this.confidence,
    this.imagePath,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _selectedStars = 0;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  // === ตั้งค่า API สำหรับบันทึกคะแนน ===
  // แก้ URL ให้ตรงกับเซิร์ฟเวอร์ของคุณ (ถ้ารันบน device จริง อย่าใช้ localhost)
  static const String _apiBase = 'http://localhost:3001';
  static const String _endpoint = '/api/feedback'; // ตัวอย่างเช่น /api/feedback

  Future<void> _submitRating() async {
    if (_selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกจำนวนดาวก่อนส่งคะแนน')),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('$_apiBase$_endpoint');

      final payload = {
        'user_id': widget.userId,
        'label': widget.predictedLabel,
        'confidence': widget.confidence, // อาจเป็น null ได้ OK
        'stars': _selectedStars,
        'comment': _commentCtrl.text.trim(),
        'image_path': widget.imagePath, // ถ้าอยากเก็บ path/ชื่อไฟล์
        'source': 'mobile', // ใส่ metadata เพิ่มเติมได้
        'created_at': DateTime.now().toIso8601String(),
      };

      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        throw Exception('ส่งคะแนนไม่สำเร็จ: ${resp.statusCode} ${resp.body}');
      }

      // สำเร็จ
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งคะแนนเรียบร้อย ขอบคุณครับ/ค่ะ')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.predictedLabel ?? '—';
    final confText = widget.confidence != null
        ? ' (${(widget.confidence! * 100).toStringAsFixed(1)}%)'
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFFDFF5DC),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                const Text(
                  'ผลการวิเคราะห์',
                  style: TextStyle(
                    color: Color.fromARGB(255, 39, 115, 42),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '"$label"$confText',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // รูปภาพ (ถ้ามี imagePath ใช้รูปจริงก่อน)
          _buildImage(widget.imagePath),

          const SizedBox(height: 16),

          // การ์ดให้คะแนน + ปุ่ม
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
              color: Colors.white,
            ),
            child: Column(
              children: [
                const Text(
                  'โปรดให้คะแนนระดับความผิดพลาด\nของการประมวลผลนี้',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 39, 115, 42),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final idx = index + 1;
                    final active = idx <= _selectedStars;
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedStars = idx;
                        });
                      },
                      icon: Icon(
                        Icons.star,
                        color: active ? Colors.amber : Colors.grey[400],
                        size: 32,
                      ),
                    );
                  }),
                ),

                // ช่องคอมเมนต์ (optional)
                const SizedBox(height: 8),
                TextField(
                  controller: _commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'มีอะไรอยากบอกเราหรือไม่ (ไม่บังคับ)',
                    fillColor: const Color(0xFFF8FFF8),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 12),

                // ปุ่มส่งคะแนน
                ElevatedButton(
                  onPressed: _submitting ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBBF7D0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _submitting ? 'กำลังส่ง...' : 'ส่งคะแนน',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(height: 28),

                // กลับไปเริ่มถ่ายรูป
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBBF7D0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ถ่ายรูปอีกครั้ง',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(height: 28),

                // ไปหน้ารายละเอียดเพิ่มเติม (ส่งข้อมูลต่อ)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnalysisResultPage(
                          userId: widget.userId,
                          imagePath: widget.imagePath,
                          predictedLabel: widget.predictedLabel,
                          confidence: widget.confidence,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text(
                    'รายละเอียดเพิ่มเติม',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 39, 115, 42),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      final f = File(imagePath);
      return Image.file(
        f,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 260,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }
    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Image.asset(
      'assets/images/manglug.jpg',
      fit: BoxFit.cover,
      width: double.infinity,
      height: 260,
    );
  }
}
