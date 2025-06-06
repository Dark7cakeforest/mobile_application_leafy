import 'package:flutter/material.dart';
import 'result.dart';

class AnalysisResultPage extends StatelessWidget {
  const AnalysisResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("After Take_pic"),
      //   backgroundColor: const Color(0xFFE9F6EA),
      //   foregroundColor: Colors.black,
      //   elevation: 0,
      // ),
      body: Column(
        children: [
          // ปุ่ม back ด้านบนพื้นหลังสีเขียวอ่อน
          Container(
            width: double.infinity,
            color: const Color(0xFFE9F6EA),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back,
                  color: Color.fromARGB(255, 11, 105, 30), size: 48),
            ),
          ),

          // ภาพพืช
          Image.asset(
            'assets/images/mangluk.jpg', // แก้ path ตามที่ใช้จริง
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // เนื้อหา
          Expanded(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Center(
                      child: Text(
                        'จากการวิเคราะห์ของเรา',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('พืชชนิดนี้ มีชื่อว่า แมงลัก\n'),
                    Text('ชื่อสามัญ คือ ******\n'),
                    Text('ชื่อวิทยาศาสตร์ คือ ***********************\n'),
                    Text('อยู่ในวงศ์ ********\n'),
                    Text(
                        'ประโยชน์ทางยา คือ\n***********************************\n***********************************\n'),
                    Text(
                        'ประโยชน์ทางอาหาร คือ\n***********************************\n***********************************\n'),
                    Text(
                        'คุณค่าทางอาหาร คือ\n***********************************\n***********************************\n'),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResultPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text(
                'ตกลง',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 39, 115, 42),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
