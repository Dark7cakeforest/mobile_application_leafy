import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'plant_model.dart';
import 'suggestion.dart';

class AnalysisResultPage extends StatefulWidget {
  final int? classId;
  final int? plantId;
  final int userId;
  final bool showSuggestionButton;
  const AnalysisResultPage({
    super.key, 
    this.classId, 
    this.plantId,
    required this.userId,
    this.showSuggestionButton = true,
  });

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  Future<Plant>? _plantFuture;

  @override
  void initState() {
    super.initState();
    // Fetch by classId if available, otherwise by plantId
    if (widget.classId != null) {
      _plantFuture = ApiService.getPlantDetails(widget.classId!);
    } else if (widget.plantId != null) {
      _plantFuture = ApiService.getPlantDetailsById(widget.plantId!);
    } else {
      throw Exception('Either classId or plantId must be provided');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Plant>(
        future: _plantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('ไม่พบข้อมูลพืช'));
          }

          final plant = snapshot.data!;

          return Column(
            children: [
              _buildHeader(context),
              Image.network(
                plant.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 100),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildDetailRow('ชื่อสามัญ:', plant.commonName),
                        _buildDetailRow('ชื่อวิทยาศาสตร์:', plant.scientificName),
                        _buildDetailRow('วงศ์:', plant.family),
                        _buildBenefitSection('ประโยชน์ทางยา:', plant.medicinalBenefits),
                        _buildBenefitSection('ประโยชน์ทางอาหาร:', plant.nutritionalBenefits),
                        _buildNutritionalSection('ตารางคุณค่าทางโภชนาการของพืช ต่อ 100 กรัม', plant.nutritionalValues),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('ชื่อสามัญ: $nameEn'),
              const SizedBox(height: 8),
              Text('ชื่อวิทยาศาสตร์: $sci'),
              const SizedBox(height: 8),
              Text('อยู่ในวงศ์: $family'),
              const SizedBox(height: 16),
              const Text('ประโยชน์ทางยา',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(medicinal),
              const SizedBox(height: 12),
              const Text('ประโยชน์ทางอาหาร',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(culinary),
              const SizedBox(height: 12),
              const Text('คุณค่าทางอาหาร',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(nutrition),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuggestionPage(userId: widget.userId),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color.fromARGB(255, 11, 105, 30)),
          ),
          child: const Center(
            child: Text(
              'ส่งข้อเสนอแนะเพิ่มเติม',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 107, 159, 108),
              ),
              if (widget.showSuggestionButton) _buildSuggestionButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE9F6EA),
      padding: const EdgeInsets.only(top: 40, left: 12, bottom: 12),
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 11, 105, 30), size: 32),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          text: '$title ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          children: [
            TextSpan(text: value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitSection(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(content ?? 'ไม่มีข้อมูล'),
        ],
      ),
    );
  }

  Widget _buildNutritionalSection(String title, List<dynamic>? content) {
    // 1. ตรวจสอบว่ามีข้อมูลหรือไม่
    if (content == null || content.isEmpty) {
      return _buildBenefitSection(title, 'ไม่มีข้อมูล');
    }

    // 2. แปลง List<dynamic> เป็น List<Map<String, dynamic>>
    //    (ข้อมูลข้างในจะเป็น Map)
    List<Map<String, dynamic>> dataList;
    try {
      dataList = content.cast<Map<String, dynamic>>();
    } catch (e) {
      return _buildBenefitSection(title, 'ข้อมูลมีรูปแบบไม่ถูกต้อง');
    }

    // 3. ค้นหา "Key" (Column) ทั้งหมดที่มีในข้อมูล
    //    ใช้ Set เพื่อป้องกัน Key ซ้ำ
    final allKeys = <String>{};
    for (final map in dataList) {
      allKeys.addAll(map.keys);
    }
    
    // 4. เรียงลำดับ Key โดยให้ 'name' อยู่แรกสุด, 'unit' อยู่ท้ายสุด
    //    และ 'amount' หรือ key อื่นๆ เช่น 'red', 'green' อยู่ตรงกลาง
    final orderedKeys = allKeys.toList();
    
    orderedKeys.sort((a, b) {
      // 'name' ต้องอยู่แรกสุดเสมอ
      if (a == 'name' && b != 'name') return -1;
      if (a != 'name' && b == 'name') return 1;
      if (a == 'name' && b == 'name') return 0;
      
      // 'unit' ต้องอยู่ท้ายสุดเสมอ
      if (a == 'unit' && b != 'unit') return 1;
      if (a != 'unit' && b == 'unit') return -1;
      if (a == 'unit' && b == 'unit') return 0;
      
      // ที่เหลือ (amount, red, green, etc.) เรียงตามตัวอักษร
      // อยู่ระหว่าง name กับ unit
      return a.compareTo(b);
    });

    // 5. สร้าง Header Row (แถวหัวข้อ) - แสดงเป็นภาษาไทยถ้าทำได้
    final headerCells = orderedKeys.map((key) {
      String displayKey = key;
      // แปลง key เป็นภาษาไทยถ้าเป็น key มาตรฐาน
      switch (key) {
        case 'name':
          displayKey = 'รายการ';
          break;
        case 'unit':
          displayKey = 'หน่วย';
          break;
        case 'amount':
          displayKey = 'ปริมาณ';
          break;
      }
      
      return TableCell(
        child: Container(
          color: const Color(0xFFE9F6EA),
          padding: const EdgeInsets.all(8.0),
          child: Text(
            displayKey,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }).toList();

    // 6. สร้าง Data Rows (แถวข้อมูล)
    final dataRows = dataList.map((map) {
      // วน Loop ตามลำดับของ orderedKeys เพื่อให้ข้อมูลตรง Column
      final cells = orderedKeys.map((key) {
        // ดึงค่าจาก map, ถ้า key ไม่มีใน map นี้ ให้ใช้ 'N/A'
        final value = map[key]?.toString() ?? 'N/A';
        return TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value,
              textAlign: (map[key] is num) ? TextAlign.right : TextAlign.left,
            ),
          ),
        );
      }).toList();
      
      return TableRow(children: cells);
    }).toList();

    // 7. ประกอบร่าง Title และ Table
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แสดง Title (หัวข้อ) ก่อน
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          // สร้างตาราง
          Table(
            border: TableBorder.all(color: Colors.grey),
            // กำหนดความกว้างของ Column อัตโนมัติ
            columnWidths: {
              for (int i=0; i<orderedKeys.length; i++)
                i: const IntrinsicColumnWidth(), // ให้คำนวณความกว้างที่เหมาะสม
            },
            children: [
              TableRow(children: headerCells), // แถว Header
              ...dataRows, // แถวข้อมูลทั้งหมด
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SuggestionPage(userId: widget.userId))),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color.fromARGB(255, 11, 105, 30)),
          ),
        ),
        child: const Text('ส่งข้อเสนอแนะเพิ่มเติม', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 107, 159, 108))),
      ),
    );
  }
}