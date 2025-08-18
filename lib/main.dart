import 'dart:io';
import 'package:flutter/material.dart';
import 'result.dart';
import 'library.dart';
import 'uploadpic.dart';
import 'analysisresult.dart';
import 'package:camera/camera.dart';

List<CameraDescription> _cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  File? file;
  CameraController? _controller;
  Future<void>? _initCamFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // เลือกกล้องหลังเป็นค่าเริ่มต้น
    if (_cameras.isNotEmpty) {
      final CameraDescription camBack = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      _onNewCameraSelected(camBack);
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription description) async {
    final oldController = _controller;
    _controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initCamFuture = _controller!.initialize();
    try {
      await _initCamFuture;
    } catch (e) {
      debugPrint('Camera init error: $e');
    } finally {
      oldController?.dispose();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // จัดการ lifecycle ของกล้อง (Android/iOS)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = _controller;
    if (cam == null || !cam.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cam.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(cam.description);
    }
  }

  Future<void> _capture() async {
    final cam = _controller;
    if (cam == null) return;

    try {
      await _initCamFuture;
      if (!mounted) return;

      final xfile = await cam.takePicture();
      final photo = File(xfile.path);
      setState(() => file = photo);

      // (แนะนำ) ส่งรูปไปหน้า ResultPage ด้วย
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            userId: 'guest',
            // ถ้าหน้า ResultPage ยังไม่มีพารามิเตอร์ รับเพิ่มเป็น imagePath หรือ file ตามต้องการ
            // imagePath: xfile.path,
          ),
        ),
      );
    } catch (e) {
      debugPrint('takePicture error: $e');
    }
  }

  @override//ส่วนต่าง ๆ เรียงจากบนลงล่าง
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color.fromARGB(255, 204, 251, 212),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PlantLibraryPage(userId: 'guest'),
                          ),
                        );
                      },
                      child: const Text(
                        'สารานุกรมพืชทั้งหมด',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 39, 115, 42),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'ค้นหาพืชที่มีอยู่ในการประมวลผล',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 107, 159, 108),
                      ),
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

            // พรีวิวกล้องเปิดทันทีเมื่อเข้าแอป
            Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 1, // ทำให้เป็นช่องสี่เหลี่ยมสวย ๆ
                child: _controller == null
                    ? const Center(child: Text('ไม่พบกล้อง'))
                    : FutureBuilder<void>(
                        future: _initCamFuture,
                        builder: (_, snap) {
                          if (snap.connectionState == ConnectionState.done) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CameraPreview(_controller!),
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
              ),
            ),

            // ปุ่มถ่าย/อัพโหลดไฟล์
            Container(
              color: const Color(0xFFE9F6EA),
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _capture,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      backgroundColor: Colors.white,
                      foregroundColor:
                          const Color.fromARGB(255, 107, 159, 108),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 11, 105, 30)),
                      ),
                    ),
                    child: const Text(
                      'เลือกไฟล์',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 107, 159, 108),
                      ),
                    ),
                    onPressed: () async {
                      final userId = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadPhotoPage(),
                        ),
                      );
                      if (!mounted) return;
                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AnalysisResultPage(userId: userId),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
