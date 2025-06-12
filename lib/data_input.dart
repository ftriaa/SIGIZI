import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataInputPage extends StatefulWidget {
  const DataInputPage({super.key});

  @override
  State<DataInputPage> createState() => _DataInputPageState();
}

class _DataInputPageState extends State<DataInputPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final Map<String, String?> dropdownValues = {};

  final List<String> numericalColumns = [
    'Umur Ibu (tahun)', 'TB (cm)', 'Jarak Hamil',
    'Tinggi Fundus Uteri (TFU)', 'Detak Jantung Janin',
    'Pemeriksaan HB', 'Panjang BBL (cm)', 'Berat BBL (gr)',
    'Sistol', 'Diastol', 'Gravida', 'Para', 'Abortus', 'Usia Kehamilan Minggu'
  ];

  final Map<String, List<String>> categoricalOptions = {
    'Jenis Asuransi': ['BPJS', 'Lainnya', 'Tidak Mempunyai Asuransi'],
    'IMT Sebelum Hamil': ['Gemuk/Obesitas', 'Kurus', 'Normal'],
    'Status Td': ['T1', 'T2', 'T3'],
    'Presentasi': ['Bagian Tubuh Lainnya', 'Belum Terdeteksi', 'Bokong', 'Kepala'],
    'Gol Darah dan Rhesus': ['A+', 'A-', 'AB+', 'AB-', 'B+', 'B-', 'O+', 'O-'],
    'Rujuk Ibu Hamil': ['Tidak', 'Ya'],
    'Faskes Rujukan': ['Puskesmas PONED', 'RS', 'Tidak Dirujuk'],
    'Konseling': ['Tidak', 'Tidak Diketahui', 'Tidak diketahui', 'Ya'],
    'Komplikasi': [
      'Abortus', 'Abortus, Perdarahan', 'Eklampsia', 'Hiperemesis Gravidarum',
      'Hipertensi Dalam Kehamilan', 'Hipertensi Dalam Kehamilan, Pre Eklampsia',
      'Infeksi', 'Infeksi, Ketuban Pecah Dini, Pre Eklampsia', 'Ketuban Pecah Dini',
      'Komplikasi Tidak Spesifik', 'Kurang Energi Kronis', 'Kurang Energi Kronis, Pre Eklampsia',
      'Obesitas', 'Perdarahan', 'Pre Eklampsia', 'Tidak Ada', 'Tidak Diketahui'
    ],
    'Cara Persalinan': ['Forceps', 'Normal', 'Sectio Caesaria', 'Vaccum'],
    'Tempat Bersalin': [
      'PMB', 'Poskesdes', 'Puskesmas', 'Pustu', 'RB', 'RS', 'RSIA',
      'Rumah', 'Tidak Diketahui', 'Tidak diketahui'
    ],
    'Penolong Persalinan': [
      'Bidan', 'Dokter Spesialis Obgyn', 'Dokter Umum', 'Dukun', 'Keluarga',
      'Lainnya', 'Spesialis', 'Tidak Diketahui', 'Tidak diketahui'
    ],
    'Kondisi Ibu': ['Hidup', 'Meninggal', 'Tidak diketahui'],
    'Kondisi Bayi': ['Hidup', 'Meninggal', 'Tidak diketahui'],
    'Komplikasi Persalinan': ['Eklampsia', 'Gemeli', 'Perdarahan', 'Pre eklampsia', 'Tidak Ada'],
    'Rujuk Ibu Bersalin (Ya / Tidak)': ['Tidak', 'Ya'],
    'Komplikasi Masa Nifas': ['Eklampsia', 'Perdarahan', 'Pre eklampsia', 'Tidak Ada'],
    'Rujuk Ibu Nifas': ['Tidak', 'Tidak diketahui', 'Ya'],
    'Kelurahan/Desa': [
      'Adiarsa', 'Anggadita', 'Balongsari', 'Batujaya', 'Bayur Lor', 'Ciampel',
      'Cibuaya', 'Cicinde', 'Cikampek', 'Cikutra', 'Cilamaya', 'Curug', 'Gempol',
      'Jayakerta', 'Jomin', 'Kalangsari', 'Karawang Kota', 'Karawang Kulon',
      'Kertamukti', 'Klari', 'Kota Baru', 'Kutamukti', 'Kutawaluya', 'Lemah Abang',
      'Lemah Duhur', 'Loji', 'Majalaya', 'Medang Asem', 'Nagasari', 'PKM Plawad',
      'PKM Telukjambe', 'PKM Wanakerta', 'Pacing', 'Pakisjaya', 'Pangkalan',
      'Pasir Rukem', 'Pedes', 'Purwasari', 'Rawamerta', 'Rengasdengklok', 'Sukatani',
      'Sungai Buntu', 'Talagasari', 'Tanjungpura', 'Tempuran', 'Tirtajaya',
      'Tirtamulya', 'Tunggakjati', 'Wadas', 'jatisari'
    ]
  };

  String? resultText;
  double? probabilityValue;

  @override
  void initState() {
    super.initState();
    for (var col in numericalColumns) {
      controllers[col] = TextEditingController();
    }
    for (var cat in categoricalOptions.keys) {
      dropdownValues[cat] = null;
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> inputs = {};
      inputs.addAll({for (var e in controllers.entries) e.key: e.value.text});
      inputs.addAll({for (var e in dropdownValues.entries) e.key: e.value});

      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/predict_kek"), // ⚠ sesuaikan jika pakai device fisik
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"inputs": inputs}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          resultText = data['prediction'];
          probabilityValue = data['probability'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memproses data")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Prediksi KEK")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...numericalColumns.map((col) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      controller: controllers[col],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: col,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Wajib diisi'
                          : null,
                    ),
                  )),
              ...categoricalOptions.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: DropdownButtonFormField<String>(
                      value: dropdownValues[entry.key],
                      items: entry.value
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => dropdownValues[entry.key] = val),
                      decoration: InputDecoration(
                        labelText: entry.key,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null ? 'Pilih salah satu' : null,
                    ),
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
                child: const Text("Prediksi KEK"),
              ),
              const SizedBox(height: 30),
              if (resultText != null && probabilityValue != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status Gizi: $resultText",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Probabilitas: ${(probabilityValue! * 100).toStringAsFixed(2)}%",
                        style: const TextStyle(fontSize: 18))
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
