import 'package:flutter/material.dart';
import 'rating.dart'; // <- หน้าที่คุณให้ผมสร้างไว้ก่อนหน้า

class PlantLibraryPage extends StatelessWidget {
  const PlantLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      // appBar: AppBar(
      //   backgroundColor: Colors.black87,
      //   title: const Text('Library_Veg'),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.green, size: 32),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ข้อมูลพืชต่าง ๆ',
                    style: TextStyle(
                        fontSize: 24,
                        color: Color.fromARGB(255, 39, 115, 42),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // แมงลัก
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RatingPage()),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/mangluk.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text('แมงลัก',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 39, 115, 42))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // พริกชี้ฟ้า
              Column(
                children: [
                  Image.asset(
                    'assets/images/chilli.jpg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  const Text('พริกชี้ฟ้า',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 39, 115, 42))),
                  const SizedBox(height: 20),
                ],
              ),
              // กะเพรา
              Column(
                children: [
                  Image.asset(
                    'assets/images/basil.jpg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  const Text('กะเพรา',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 39, 115, 42))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
