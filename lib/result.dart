import 'dart:io';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'thankyou.dart';

class ResultPage extends StatelessWidget {
  final File imageFile;
  final Map<String, dynamic> predictionResult;

  const ResultPage({
    super.key,
    required this.imageFile,
    required this.predictionResult,
  });

  void _sendFeedbackAndNavigate(BuildContext context, bool isCorrect) async {
    try {
      await ApiService.sendFeedback(predictionResult['result_id'], isCorrect);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ThankYouPage(predictionResult: predictionResult)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantInfo = predictionResult['plant_info'];
    final confidence = (predictionResult['confidence'] * 100).toStringAsFixed(2);
    final plantName = plantInfo['name'];

    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFDFF5DC),
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 16),
            child: Column(
              children: [
                const Text('ผลการวิเคราะห์', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 115, 42))),
                Text('"$plantName"', style: const TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold)),
                Text('(ความมั่นใจ $confidence%)', style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ],
            ),
          ),
          Image.file(
            imageFile,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 260,
          ),
          const SizedBox(height: 16),
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
                const Text('ผลลัพธ์นี้ทำนายได้แม่นยำหรือไม่', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 115, 42))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 60,
                      onPressed: () => _sendFeedbackAndNavigate(context, true),
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                    IconButton(
                      iconSize: 60,
                      onPressed: () => _sendFeedbackAndNavigate(context, false),
                      icon: const Icon(Icons.cancel, color: Colors.red),
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
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: ElevatedButton(
              onPressed: () {
                // กลับไปหน้าแรกสุด (หน้ากล้อง)
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('ถ่ายรูปใหม่อีกครั้ง'),
            ),
          ),
        ],
      ),
    );
  }
}
