import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _selectedStars = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      // appBar: AppBar(
      //   backgroundColor: Colors.black87,
      //   title: const Text('Take Picture5'),
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
                    color: Color.fromARGB(255, 39, 115, 42),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
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
            'assets/images/mangluk.jpg',
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
                  'โปรดให้คะแนนระดับความผิดพลาด\nของการประมวลผลนี้',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 39, 115, 42),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedStars = index + 1;
                        });
                      },
                      icon: Icon(
                        Icons.star,
                        color: index < _selectedStars
                            ? Colors.amber
                            : Colors.grey[400],
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // กลับไปเริ่มถ่ายรูป
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
                ElevatedButton(
                  onPressed: () {
                    // ไปหน้ารายละเอียดเพิ่มเติม
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
