import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String jenisKelamin = 'Perempuan';
  String pemeriksaan = 'Ya';
  String pendidikan = 'Tingkat SMA';
  String predictionResult = '';
  bool isLoading = false;

  final _dropdownOptions = {
    'Jenis kelamin': ['Laki-laki', 'Perempuan'],
    'Apakah ibu dan anak melakukan pemeriksaan setelan 40 hari kelahiran?': ['Ya', 'Tidak'],
    'Tingkat pendidikan kepala keluarga': ['Tingkat SD', 'Tingkat SMP', 'Tingkat SMA', 'Pendidikan Tinggi', 'Tidak sekolah'],
  };

  final List<String> numericFields = [
    'Usia anak (bulan)', 'Berat badan anak saat ini (kg)', 'Tinggi badan anak saat ini (cm)',
    'Berat badan anak saat lahir (kg)', 'Usia anak pertama kali disapih (bulan)',
    'Jumlah pemeriksaan yang dilakukan ibu saat hamil', 'Frekuensi anak makan ubi dalam 1 minggu',
    'Frekuensi anak makan telur dalam 1 minggu', 'Frekuensi anak makan ikan dalam 1 minggu',
    'Frekuensi anak makan daging dalam 1 minggu', 'Frekuensi anak minum susu dalam 1 minggu',
    'Frekuensi anak makan sayur dalam 1 minggu', 'Frekuensi anak makan pisang dalam 1 minggu',
    'Frekuensi anak makan pepaya dalam 1 minggu', 'Frekuensi anak makan wortel dalam 1 minggu',
    'Frekuensi anak makan mangga dalam 1 minggu', 'Frekuensi anak makan mie dalam 1 minggu',
    'Frekuensi anak makan fast food dalam 1 minggu', 'Frekuensi anak minum soda dalam 1 minggu',
    'Frekuensi anak makan sambal dalam 1 minggu', 'Frekuensi anak makan gorengan dalam 1 minggu',
    'Frekuensi anak makan nasi dalam 1 minggu', 'Frekuensi anak makan makanan manis dalam 1 minggu',
    'Pendapatan keluarga perbulan (Rp)'
  ];

  @override
  void initState() {
    for (var field in numericFields) {
      _controllers[field] = TextEditingController();
    }
    super.initState();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      "inputs": {
        'Jenis kelamin': jenisKelamin,
        'Apakah ibu dan anak melakukan pemeriksaan setelan 40 hari kelahiran?': pemeriksaan,
        'Tingkat pendidikan kepala keluarga': pendidikan,
        for (var field in numericFields)
          field: _controllers[field]!.text
      }
    };

    setState(() {
      isLoading = true;
      predictionResult = '';
    });

    try {
      final res = await http.post(
        Uri.parse('http://localhost:8000/predict_stunting'), // Ganti IP jika pakai emulator
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final result = jsonDecode(res.body);
        setState(() {
          predictionResult =
              "Prediksi: ${result['prediction']}, Kemungkinan Stunting: ${(result['probability'] * 100).toStringAsFixed(1)}%";
        });
      } else {
        setState(() {
          predictionResult = 'Gagal mendapatkan prediksi. (${res.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        predictionResult = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: _controllers[label],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Guidance')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Data Anak", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildDropdown('Jenis kelamin', jenisKelamin, _dropdownOptions['Jenis kelamin']!, (val) {
              setState(() => jenisKelamin = val!);
            }),
            _buildTextField('Usia anak (bulan)'),
            _buildTextField('Berat badan anak saat ini (kg)'),
            _buildTextField('Tinggi badan anak saat ini (cm)'),
            _buildDropdown('Apakah ibu dan anak melakukan pemeriksaan setelan 40 hari kelahiran?', pemeriksaan, _dropdownOptions['Apakah ibu dan anak melakukan pemeriksaan setelan 40 hari kelahiran?']!, (val) {
              setState(() => pemeriksaan = val!);
            }),
            _buildTextField('Berat badan anak saat lahir (kg)'),
            _buildTextField('Usia anak pertama kali disapih (bulan)'),
            _buildTextField('Jumlah pemeriksaan yang dilakukan ibu saat hamil'),

            const SizedBox(height: 12),
            const Text("Frekuensi Konsumsi Anak (per minggu)", style: TextStyle(fontWeight: FontWeight.bold)),
            for (var field in numericFields.where((f) => f.contains('Frekuensi')))
              _buildTextField(field),

            _buildDropdown('Tingkat pendidikan kepala keluarga', pendidikan, _dropdownOptions['Tingkat pendidikan kepala keluarga']!, (val) {
              setState(() => pendidikan = val!);
            }),
            _buildTextField('Pendapatan keluarga perbulan (Rp)'),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _sendRequest,
              child: isLoading ? const CircularProgressIndicator() : const Text("Prediksi Risiko"),
            ),
            const SizedBox(height: 12),
            Text(predictionResult, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
