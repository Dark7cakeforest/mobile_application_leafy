import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlantDetailPage extends StatefulWidget {
  final int plantId; // <- รับ id มาตรง ๆ
  const PlantDetailPage({super.key, required this.plantId});

  @override
  State<PlantDetailPage> createState() => _PlantDetailPageState();
}

class _PlantDetailPageState extends State<PlantDetailPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _plant;

  String get _apiBase {
    const port = 5001; // Flask
    if (Platform.isAndroid) return 'http://10.0.2.2:$port';
    return 'http://localhost:$port';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('$_apiBase/api/plant/${widget.plantId}');
      final resp = await http.get(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) {
        throw Exception('โหลดไม่สำเร็จ: ${resp.statusCode} ${resp.body}');
      }
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      if (data is! Map) throw Exception('รูปแบบข้อมูลไม่ถูกต้อง');

      if (!mounted) return;
      setState(() {
        _plant = Map<String, dynamic>.from(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ---------- Helpers ----------
  String _render(dynamic v) {
    if (v == null) return '—';
    if (v is String) return v.trim().isEmpty ? '—' : v;
    if (v is List) {
      // list เป็นบูลเล็ต
      final items = v.map((e) => '• ${_render(e)}').join('\n');
      return items.isEmpty ? '—' : items;
    }
    if (v is Map) {
      // key-value เป็นบูลเล็ต
      final items =
          v.entries.map((e) => '• ${e.key}: ${_render(e.value)}').join('\n');
      return items.isEmpty ? '—' : items;
    }
    return v.toString();
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Color.fromARGB(255, 11, 105, 30), size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('เกิดข้อผิดพลาด:\n$_error',
                          style: const TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                        onPressed: _load, child: const Text('ลองใหม่')),
                  ],
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // image
                      if ((_plant?['image_url'] ?? '').toString().isNotEmpty)
                        Image.network(
                          _plant!['image_url'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            height: 180,
                            child: Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _plant?['name_th'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('ชื่อสามัญ: ${_render(_plant?['name_en'])}'),
                            const SizedBox(height: 8),
                            Text(
                                'ชื่อวิทยาศาสตร์: ${_render(_plant?['sci_name'])}'),
                            const SizedBox(height: 8),
                            Text('อยู่ในวงศ์: ${_render(_plant?['family'])}'),
                            _sectionTitle('ประโยชน์ทางยา'),
                            Text(_render(_plant?['medicinal'])),
                            _sectionTitle('ประโยชน์ทางอาหาร'),
                            Text(_render(_plant?['culinary'])),
                            _sectionTitle('คุณค่าทางอาหาร'),
                            Text(_render(_plant?['nutrition'])),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
