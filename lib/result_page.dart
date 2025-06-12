import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map result = ModalRoute.of(context)!.settings.arguments as Map;
    final prediction = result['prediction'];
    final probability = result['probability'];

    return Scaffold(
      appBar: AppBar(title: const Text("Prediction Result")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Status Gizi: $prediction", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Probabilitas: ${(probability * 100).toStringAsFixed(2)}%", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: const Text("Kembali ke Beranda"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
