// lib/suggestion.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitSuggestion() async {
    final suggestion = _controller.text.trim();
    if (suggestion.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiService.submitSuggestion(suggestion);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("ส่งสำเร็จ"),
            content: const Text("ขอบคุณสำหรับข้อเสนอแนะของคุณ!"),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("ตกลง"))],
          ),
        ).then((_) => Navigator.of(context).pop()); // กลับไปหน้าก่อนหน้าหลังกดตกลง
        _controller.clear();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("เกิดข้อผิดพลาด"),
            content: Text("ไม่สามารถส่งข้อเสนอแนะได้\n$e"),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("ตกลง"))],
          ),
        );
      }
    } finally {
       if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      appBar: AppBar(
        title: const Text('ส่งข้อเสนอแนะ'),
        backgroundColor: const Color.fromARGB(255, 204, 251, 212),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("ข้อเสนอแนะของคุณ:", style: TextStyle(color: Color.fromARGB(255, 39, 115, 42), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'พิมพ์ข้อเสนอแนะที่นี่...',
                hintStyle: const TextStyle(color: Color.fromARGB(255, 107, 159, 108)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitSuggestion,
              icon: _isSubmitting ? const SizedBox.shrink() : const Icon(Icons.send),
              label: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("ส่งข้อเสนอแนะ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 39, 115, 42),
                foregroundColor: Colors.white,
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