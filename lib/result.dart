import 'package:flutter/material.dart';
import 'thankyou.dart';
import 'analysisresult.dart';

class ResultPage extends StatelessWidget {
  final String userId;
  const ResultPage({super.key, this.userId = 'guest'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      // appBar: AppBar(
      //   backgroundColor: Colors.black87,
      //   title: const Text('Take Picture3'),
      // ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFDFF5DC),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: const [
                Text(
                  'ผลการวิเคราะห์',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 39, 115, 42)),
                ),
                Text(
                  '"แมงลัก"',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/manglug.jpg',
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
                const Text(
                  'ผลลัพธ์นี้ทำนายได้แม่นยำหรือไม่',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 39, 115, 42),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 60,
                      onPressed: () {
                        // บันทึกว่าผู้ใช้พอใจ
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ThankYouPage(userId: userId)),
                        );
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                    IconButton(
                      iconSize: 60,
                      onPressed: () {
                        // บันทึกว่าผู้ใช้ไม่พอใจ
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RatingPage(userId: userId)),
                        );
                      },
                      icon: const Icon(Icons.cancel, color: Colors.red),
                    ),
                  ],
                ),
                const Divider(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // ไปหน้ารายละเอียดเพิ่มเติม
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AnalysisResultPage(userId: userId)),
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
}
