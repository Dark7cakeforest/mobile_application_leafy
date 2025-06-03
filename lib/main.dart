import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaf&Pepper Detect',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 204, 251, 212)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'สารานุกรมพืชทั้งหมด'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              color: const Color.fromARGB(255, 204, 251, 212), // เขียวอ่อน
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 39, 115, 42),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'ค้นหาพืชที่มีอยู่ในการประมวลผล',
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 107, 159, 108)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White area (รายการว่าง)
            Expanded(
              child: Container(
                color: Colors.white,
              ),
            ),

            // Bottom section (กล้อง + เลือกไฟล์)
            Container(
              color: const Color(0xFFE9F6EA),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'หรือ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 39, 115, 42),
                    ),
                  ),
                  const Text(
                    'นำเข้ารูปภาพจากไฟล์',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 39, 115, 42),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: เพิ่ม logic เลือกไฟล์
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Color.fromARGB(255, 11, 105, 30)),
                      ),
                      child: Center(
                        child: Text(
                          'เลือกไฟล์',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 107, 159, 108),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // const SizedBox(height: 12),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // TODO: ใส่โค้ดเลือกไฟล์
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.white,
                  //     side: const BorderSide(
                  //         color: Color.fromARGB(255, 11, 105, 30)),
                  //     padding: const EdgeInsets.symmetric(
                  //         vertical: 12, horizontal: 32),
                  //   ),
                  //   child: const Text(
                  //     'เลือกไฟล์',
                  //     style: TextStyle(
                  //       fontSize: 18,
                  //       color: Color.fromARGB(255, 39, 115, 42),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
