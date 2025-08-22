import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadPhotoPage extends StatefulWidget {
  const UploadPhotoPage({super.key});

  @override
  State<UploadPhotoPage> createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  File? _image;
  bool _isUploading = false;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> uploadImage() async {
    if (_image == null) return;

    setState(() => _isUploading = true);

    var uri =
        Uri.parse("http://172.23.227.237:5001/upload"); // หรือ IP บนมือถือคุณ
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();
    print("📤 กำลังส่งรูปภาพ: ${_image!.path}");
    print("📡 URL: $uri");

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      final userId = data['user_id'];

      if (!mounted) return;
      Navigator.pop(context, userId); // ส่งกลับไปยัง MyHomePage
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("อัปโหลดล้มเหลว")));
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("อัปโหลดภาพ")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20), //เว้น
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text("ยังไม่เลือกรูป"),
            const SizedBox(height: 20), //เว้น
            ElevatedButton(
                onPressed: pickImage, child: const Text("เลือกรูปภาพ")),
            const SizedBox(height: 10), //เว้น
            ElevatedButton(
              onPressed: _isUploading ? null : uploadImage,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text("อัปโหลด"),
            ),
          ],
        ),
      ),
    );
  }
}
