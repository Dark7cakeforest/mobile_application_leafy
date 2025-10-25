import 'package:flutter/material.dart';
import 'api_service.dart';
import 'plant_model.dart';
import 'suggestion.dart';

class AnalysisResultPage extends StatefulWidget {
  final int classId;
  final int userId;
  const AnalysisResultPage({super.key, required this.classId, required this.userId});

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  Future<Plant>? _plantFuture;

  @override
  void initState() {
    super.initState();
    _plantFuture = ApiService.getPlantDetails(widget.classId);
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
                      ],
                    ),
                  ),
                ),
              ),
              _buildSuggestionButton(context),
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