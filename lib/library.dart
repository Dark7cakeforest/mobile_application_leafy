import 'package:flutter/material.dart';
import 'analysisresult.dart';

class PlantLibraryPage extends StatelessWidget {
  final String userId;
  const PlantLibraryPage({super.key, this.userId = 'guest'});

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
                    MaterialPageRoute(
                        builder: (context) =>
                            AnalysisResultPage(userId: userId)),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/manglug.jpg',
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
                    'assets/images/shifa.jpg',
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
                    'assets/images/kaprao.jpg',
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
              //วนลูปแสดงข้อมูลพืชจากฐานข้อมูล
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AnalysisResultPage(userId: userId)),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/horapa.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text('โหระพา',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 39, 115, 42))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              //วนลูปแสดงข้อมูลพืชจากฐานข้อมูล2
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AnalysisResultPage(userId: userId)),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/jinda.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text('พริกจินดา',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 39, 115, 42))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              //วนลูปแสดงข้อมูลพืชจากฐานข้อมูล3
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AnalysisResultPage(userId: userId)),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/kareang.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text('พริกกะเหรี่ยง',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 39, 115, 42))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              //วนลูปแสดงข้อมูลพืชจากฐานข้อมูล4
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AnalysisResultPage(userId: userId)),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/jinda.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text('พริกจินดา',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 39, 115, 42))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              //วนลูปแสดงข้อมูลพืชจากฐานข้อมูล5
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AnalysisResultPage(userId: userId)),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/kheenhu.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text('พริกขี้หนู',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 39, 115, 42))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              //วนลูปแสดงข้อมูลพืชจากฐานข้อมูล6
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AnalysisResultPage(userId: userId)),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/nhum.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text('พริกหนุ่ม',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 39, 115, 42))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              //วนลูปแสดงข้อมูลพืชจากฐานข้อมูล7
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AnalysisResultPage(userId: userId)),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/saranae.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text('สะระแหน่',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 39, 115, 42))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              //วนลูปแสดงข้อมูลพืชจากฐานข้อมูล8
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AnalysisResultPage(userId: userId)),
                  );
                },
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/yhira.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text('ยี่หร่า',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 39, 115, 42))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
