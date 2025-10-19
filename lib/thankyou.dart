import 'dart:io';
import 'package:flutter/material.dart';
import 'analysisresult.dart';

class ThankYouPage extends StatelessWidget {
  final String userId;

  /// ข้อมูลจาก AI/ResultPage (ส่งมาได้จะโชว์แบบไดนามิก)
  final String? predictedLabel; // เช่น "แมงลัก"
  final double? confidence; // 0..1
  final String? imagePath; // รูปที่ผู้ใช้ถ่าย/อัปโหลด

  /// สถิติโมเดล (จะมาจาก backend หรือส่งมาก็ได้)
  final double? modelAvgAccuracy; // 0..1 เช่น 0.75 => 75%
  final int? totalInferences; // จำนวนครั้งที่ประมวลผล

  const ThankYouPage({
    super.key,
    this.userId = 'guest',
    this.predictedLabel,
    this.confidence,
    this.imagePath,
    this.modelAvgAccuracy,
    this.totalInferences,
  });

  @override
  Widget build(BuildContext context) {
    final label = predictedLabel ?? '—';
    final confText = confidence != null
        ? ' (${(confidence! * 100).toStringAsFixed(1)}%)'
        : '';

    final avgAccPct = modelAvgAccuracy != null
        ? (modelAvgAccuracy! * 100).toStringAsFixed(0)
        : '75'; // fallback เดิม
    final totalInf = totalInferences?.toString() ?? '20'; // fallback เดิม

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
          _buildImage(imagePath),

          const SizedBox(height: 16),

          // การ์ดข้อความ + ปุ่ม
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
                  'ขอบคุณสำหรับ\nความคิดเห็นของคุณ!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 39, 115, 42),
                  ),
                ),
                const SizedBox(height: 16),

                // สถิติโมเดล (ไดนามิก/มี fallback)
                Text.rich(
                  TextSpan(
                    text: 'โมเดลตัวนี้มีความแม่นยำเฉลี่ย ',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 39, 115, 42),
                    ),
                    children: [
                      TextSpan(
                        text: '$avgAccPct%',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: ' โดยผ่านการประมวลผล\nมาจำนวน ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 39, 115, 42),
                        ),
                      ),
                      TextSpan(
                        text: totalInf,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' ครั้ง'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // กลับไปเริ่มต้น
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

                const Divider(height: 32),

                // ไปหน้ารายละเอียดเพิ่มเติม (ส่งข้อมูลต่อให้ครบ)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnalysisResultPage(
                          userId: userId,
                          imagePath: imagePath,
                          predictedLabel: predictedLabel,
                          confidence: confidence,
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
