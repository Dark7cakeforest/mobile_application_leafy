import 'package:flutter/material.dart';
import 'analysisresult.dart';
import 'main.dart';

class ThankYouPage extends StatelessWidget {
  final Map<String, dynamic> predictionResult;
  const ThankYouPage({super.key, required this.predictionResult});

  @override
  Widget build(BuildContext context) {
    final plantInfo = predictionResult['plant_info'];
    final plantName = plantInfo['name'];
    final classId = predictionResult['class_id'];
    final guestUserId = predictionResult['guest_user_id'];

    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 115, 42)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MyHomePage(title: '')),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBBF7D0),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ถ่ายรูปอีกครั้ง', style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnalysisResultPage(classId: classId, userId: guestUserId,)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    'รายละเอียดเพิ่มเติมของ "$plantName"',
                    style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 39, 115, 42), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}