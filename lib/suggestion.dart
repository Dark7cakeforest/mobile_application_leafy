import 'package:flutter/material.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _controller = TextEditingController();

  void _submitSuggestion() {
    final suggestion = _controller.text;
    if (suggestion.isNotEmpty) {
      // ทำสิ่งที่คุณต้องการกับข้อความ เช่น ส่งไปเก็บในฐานข้อมูล
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 204, 251, 212),
        // title: const Text('ส่งข้อเสนอแนะ'),
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
                backgroundColor: Color.fromARGB(255, 204, 251, 212),
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
