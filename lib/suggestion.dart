import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuggestionPage extends StatefulWidget {
  final String userId; // รับ user_id จากหน้าก่อนหน้า
  const SuggestionPage({super.key, required this.userId});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _submitSuggestion() async {
    final suggestion = _controller.text.trim();
    if (suggestion.isEmpty) return;

    final url = Uri.parse(
        'http://172.23.227.237:5001/submit_suggestion'); // 🔁 เปลี่ยนเป็น IP เครื่องคุณถ้าใช้มือถือจริง

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'message': suggestion,
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("ส่งสำเร็จ"),
            content: const Text("ขอบคุณสำหรับข้อเสนอแนะของคุณ!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("ตกลง"),
              )
            ],
          ),
        );
        _controller.clear();
      } else {
        throw Exception("รหัสผิดพลาด: ${response.statusCode}");
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("เกิดข้อผิดพลาด"),
          content: Text("ไม่สามารถส่งข้อเสนอแนะได้\n$e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ตกลง"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 204, 251, 212),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.green[700],
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "ข้อเสนอแนะของคุณ:",
              style: TextStyle(
                  color: Color.fromARGB(255, 39, 115, 42),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'พิมพ์ข้อเสนอแนะที่นี่...',
                hintStyle:
                    const TextStyle(color: Color.fromARGB(255, 107, 159, 108)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitSuggestion,
              icon: const Icon(Icons.send),
              label: const Text("ส่งข้อเสนอแนะ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 204, 251, 212),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
