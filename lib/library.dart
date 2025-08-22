// plant_library_page.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'plant_detail.dart'; // <- ใช้กับหน้าแสดงรายละเอียดตามที่ให้ไปก่อนหน้า

/// =====================
/// Model & API helpers
/// =====================
class Plant {
  final int plantId;
  final String nameTh;
  final String nameEn;
  final String imageUrl;
  final int? classId;

  Plant({
    required this.plantId,
    required this.nameTh,
    required this.nameEn,
    required this.imageUrl,
    this.classId,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: (json['plant_id'] as num).toInt(),
      nameTh: (json['name_th'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      classId: json['ai_class_id'] == null
          ? null
          : (json['ai_class_id'] as num).toInt(),
    );
  }
}

String get _apiBase {
  const port = 5001; // Flask
  if (Platform.isAndroid) return 'http://10.0.2.2:$port';
  return 'http://localhost:$port';
}

Future<List<Plant>> fetchPlants() async {
  final uri = Uri.parse('$_apiBase/api/plants');
  final resp = await http.get(uri).timeout(const Duration(seconds: 20));
  if (resp.statusCode != 200) {
    throw Exception('โหลดรายการพืชไม่สำเร็จ: ${resp.statusCode} ${resp.body}');
  }
  final data = jsonDecode(utf8.decode(resp.bodyBytes));
  final list = (data['plants'] as List?) ?? [];
  return list.map((e) => Plant.fromJson(e as Map<String, dynamic>)).toList();
}

/// =====================
/// UI: PlantLibraryPage
/// =====================
class PlantLibraryPage extends StatefulWidget {
  final String userId;
  const PlantLibraryPage({super.key, this.userId = 'guest'});

  @override
  State<PlantLibraryPage> createState() => _PlantLibraryPageState();
}

class _PlantLibraryPageState extends State<PlantLibraryPage> {
  late Future<List<Plant>> _future;
  List<Plant> _all = [];
  List<Plant> _filtered = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _load();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<Plant>> _load() async {
    final items = await fetchPlants();
    _all = items;
    _filtered = items;
    return items;
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = _all);
      return;
    }
    setState(() {
      _filtered = _all.where((p) {
        return p.nameTh.toLowerCase().contains(q) ||
            p.nameEn.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _refresh() async {
    final items = await _load();
    setState(() {
      _all = items;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F6EA),
      body: SafeArea(
        child: FutureBuilder<List<Plant>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _ErrorView(
                message: 'เกิดข้อผิดพลาด: ${snap.error}',
                onRetry: () {
                  setState(() => _future = _load());
                },
              );
            }
            // ปกติ _filtered ถูกเซ็ตใน _load แล้ว แต่กันกรณีขอบ
            final plants = _filtered;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.green, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ข้อมูลพืชต่าง ๆ',
                            style: TextStyle(
                              fontSize: 24,
                              color: Color.fromARGB(255, 39, 115, 42),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                      child: _SearchBox(controller: _searchCtrl),
                    ),
                  ),
                  if (plants.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('ไม่พบข้อมูลพืช')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final p = plants[index];
                            return _PlantCard(
                              plant: p,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PlantDetailPage(plantId: p.plantId),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: plants.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// =====================
/// Widgets
/// =====================
class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'ค้นหาพืช (ชื่อไทย/อังกฤษ)',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 39, 115, 42)),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  const _PlantCard({required this.plant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          // ภาพ
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                plant.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Colors.black12),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ชื่อไทย
          Text(
            plant.nameTh,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 39, 115, 42),
              fontWeight: FontWeight.w600,
            ),
          ),
          // ชื่ออังกฤษ (ถ้ามี)
          if (plant.nameEn.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              plant.nameEn,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red)),
        ),
        ElevatedButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        const Spacer(),
      ],
    );
  }
}
