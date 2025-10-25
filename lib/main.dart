import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'result.dart';
import 'library.dart';

// Set to false to disable CameraPreview (useful for running on emulators that
// have rendering/camera issues). Set to true when testing on a real device.
const bool kEnableCameraPreview = false;

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 204, 251, 212)),
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Only initialize camera when preview is enabled to avoid emulator crashes
    if (kEnableCameraPreview && _cameras.isNotEmpty) {
      _onNewCameraSelected(_cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      ));
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription description) async {
    final oldController = _controller;
    _controller = CameraController(description, ResolutionPreset.high, enableAudio: false);
    // Await initialize here so analyzer knows the controller is initialized when used
    try {
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Camera initialize error: $e');
    }
    await oldController?.dispose();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

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

  Future<void> _processImage(File imageFile) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await ApiService.predictImage(imageFile);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              imageFile: imageFile,
              predictionResult: result,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _capture() async {
    final cam = _controller;
    if (cam == null || !cam.value.isInitialized) return;
    try {
      final xfile = await cam.takePicture();
      _processImage(File(xfile.path));
    } catch (e) {
      debugPrint('takePicture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _processImage(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      body: SafeArea(
        child: _isProcessing
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('กำลังประมวลผล...', style: TextStyle(fontSize: 18, color: Colors.green)),
                  ],
                ),
              )
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildCameraPreview()),
                  _buildControls(),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color.fromARGB(255, 204, 251, 212),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlantLibraryPage())),
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
    );
  }

  Widget _buildCameraPreview() {
    // If preview is disabled, show a safe placeholder so the app can run on
    // emulators that otherwise crash with CameraPreview/native surface texture.
    if (!kEnableCameraPreview) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.photo_camera_front, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Camera preview disabled for emulator', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: Text('กำลังเปิดกล้อง...'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: const Color(0xFFE9F6EA),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _capture,
            child: Container(width: 80, height: 80, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
          ),
          const SizedBox(height: 16),
          const Text('หรือ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 115, 42))),
          const Text('นำเข้ารูปภาพจากไฟล์', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 39, 115, 42))),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              backgroundColor: Colors.white,
              foregroundColor: const Color.fromARGB(255, 107, 159, 108),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color.fromARGB(255, 11, 105, 30)),
              ),
            ),
            onPressed: _pickFromGallery,
            child: const Text('เลือกไฟล์', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}