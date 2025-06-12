import 'package:flutter/material.dart';

void main() {
  runApp(const HealthDataApp());
}

class HealthDataApp extends StatelessWidget {
  const HealthDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HealthHomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const Placeholder(),        // Ganti nanti dengan LoginPage
        '/dataInput': (context) => const Placeholder(),    
      },
    );
  }
}

class HealthHomePage extends StatelessWidget {
  const HealthHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Data Form'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.png'),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter health data, get predictions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Risk Prediction Results", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildCard(Icons.verified_user, "Prediksi KEK", "View", context),
          const SizedBox(height: 10),
          _buildCard(Icons.restaurant, "Prediksi Stunting", "View", context),
          const SizedBox(height: 30),
          _buildCard(Icons.chat, "Chatbot", "Chat", context),
          const SizedBox(height: 30),
          const Text("AI Chat for Nutrition Help", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String buttonText, BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        trailing: ElevatedButton(
          onPressed: () {
            if (title == "Prediksi KEK") {
              Navigator.pushNamed(context, '/dataInput');
            } else if (title == "Prediksi Stunting") {
              Navigator.pushNamed(context, '/nutrition');
            } else if (title == "Chatbot") {
              Navigator.pushNamed(context, '/chatbot'); // ✅ BUTTON CHATBOT TERHUBUNG
            }
          },
          child: Text(buttonText),
        ),
      ),
    );
  }
}

class _BottomIconCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomIconCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(child: Icon(icon, color: Colors.white), backgroundColor: Colors.black),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
