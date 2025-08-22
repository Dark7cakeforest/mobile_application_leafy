import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'thankyou.dart';
import 'rating.dart';
import 'analysisresult.dart';

class ResultPage extends StatefulWidget {
  final String userId;
  final String imagePath; // ✅ รับพาธรูปที่จะส่งให้ AI

  const ResultPage({
    super.key,
    this.userId = 'guest',
    required this.imagePath,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  // === ตั้งค่า API ของ AI ที่นี่ ===
  // ตัวอย่าง: Node/Express ที่คุณทำไว้: POST /api/predict
  // รับ multipart field ชื่อ "image"
  static const String _apiBase = 'http://localhost:3001';
  static const String _endpoint = '/api/predict';

  bool _loading = true;
  String? _error;
  String? _label; // label หลักจาก AI เช่น "แมงลัก"
  double? _confidence; // ความมั่นใจ (0..1)
  List<Map<String, dynamic>> _topK = []; // optional: top-5

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final file = File(widget.imagePath);
      if (!await file.exists()) {
        throw Exception('ไม่พบไฟล์ภาพที่พาธ: ${widget.imagePath}');
      }

      final uri = Uri.parse('$_apiBase$_endpoint');
      final req = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath('image', widget.imagePath),
        );

      // ถ้าต้องการส่ง userId ไปด้วย
      req.fields['user_id'] = widget.userId;

      // ตั้ง timeout ให้ชัดเจน
      final streamed = await req.send().timeout(const Duration(seconds: 30));
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode != 200) {
        throw Exception(
            'AI API ตอบกลับด้วยสถานะ ${resp.statusCode}: ${resp.body}');
      }

      final data = jsonDecode(resp.body);

      // ====== ตัวอย่างโครงสร้าง JSON ที่คาดหวัง ======
      // {
      //   "label": "แมงลัก",
      //   "confidence": 0.9732,
      //   "top_k": [
      //     {"label": "แมงลัก", "prob": 0.9732},
      //     {"label": "กะเพรา", "prob": 0.0121},
      //     {"label": "โหระพา", "prob": 0.0083}
      //   ]
      // }
      // ปรับ mapping ให้สอดคล้องกับ backend ของคุณ

      setState(() {
        _label = (data['label'] ?? '').toString();
        final conf = data['confidence'];
        _confidence = conf is num ? conf.toDouble() : null;

        final tk = data['top_k'];
        if (tk is List) {
          _topK = tk
              .map<Map<String, dynamic>>((e) => {
                    'label': e['label'],
                    'prob': (e['prob'] is num)
                        ? (e['prob'] as num).toDouble()
                        : null,
                  })
              .toList();
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildHeader() {
    final title = 'ผลการวิเคราะห์';
    final showLabel = _label ?? '-';
    final confText = _confidence != null
        ? ' (${(_confidence! * 100).toStringAsFixed(1)}%)'
        : '';

    return Container(
      color: const Color(0xFFDFF5DC),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 39, 115, 42),
            ),
          ),
          const SizedBox(height: 4),
          if (_loading) ...[
            const Text('กำลังประมวลผล...',
                style: TextStyle(fontSize: 16, color: Colors.black54)),
          ] else if (_error != null) ...[
            const Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(
                  fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ] else ...[
            Text(
              '"$showLabel"$confText',
              style: const TextStyle(
                  fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Image.file(
      File(widget.imagePath),
      fit: BoxFit.cover,
      width: double.infinity,
      height: 260,
      errorBuilder: (_, __, ___) => const SizedBox(
        height: 260,
        child: Center(child: Text('แสดงภาพไม่สำเร็จ')),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _analyzeImage,
              child: const Text('ลองใหม่อีกครั้ง'),
            ),
          ],
        ),
      );
    }

    return Container(
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
            'ผลลัพธ์นี้ทำนายได้แม่นยำหรือไม่',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 39, 115, 42),
            ),
          ),
          const SizedBox(height: 16),
          // ปุ่ม feedback
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: 60,
                onPressed: () {
                  // ✅ สามารถส่ง feedback พร้อม label/conf ไปเก็บเพิ่มได้
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThankYouPage(userId: widget.userId),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle, color: Colors.green),
              ),
              IconButton(
                iconSize: 60,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RatingPage(userId: widget.userId),
                    ),
                  );
                },
                icon: const Icon(Icons.cancel, color: Colors.red),
              ),
            ],
          ),

          // แสดง top-k (ถ้ามี)
          if (_topK.isNotEmpty) ...[
            const Divider(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ตัวเลือกใกล้เคียง:',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 39, 115, 42),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ..._topK.map((m) {
              final lbl = m['label']?.toString() ?? '-';
              final p = (m['prob'] is double) ? (m['prob'] as double) : null;
              final pct = p != null ? (p * 100).toStringAsFixed(1) : '?';
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(lbl),
                  Text('$pct%'),
                ],
              );
            }).toList(),
          ],

          const Divider(height: 32),
          ElevatedButton(
            onPressed: () {
              // ไปหน้ารายละเอียดเพิ่มเติม (ส่งข้อมูลประกอบไปด้วยก็ได้)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalysisResultPage(
                    userId: widget.userId,
                    // ตัวอย่าง: ส่ง label/score ไปแสดงต่อ
                    // predictedLabel: _label,
                    // confidence: _confidence,
                    // imagePath: widget.imagePath,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      body: Column(
        children: [
          _buildHeader(),
          _buildPreview(),
          const SizedBox(height: 16),
          _buildResultCard(),
        ],
      ),
    );
  }
}
