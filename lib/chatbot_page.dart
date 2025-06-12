import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  final String apiUrl = "http://127.0.0.1:8000/predict"; // <- FastAPI endpoint

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['response'] ?? "Tidak ada respons."; // ✅ Di sini diperbaiki

        setState(() {
          _messages.add({'text': reply, 'isUser': false});
        });
      } else {
        setState(() {
          _messages.add({'text': 'Server error: ${response.statusCode}', 'isUser': false});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Gagal terhubung ke server. Pastikan FastAPI aktif.', 'isUser': false});
      });
    }

    _controller.clear();
  }

  Widget _buildMessage(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot SIGIZI"),
        actions: const [
          Icon(Icons.call),
          SizedBox(width: 8),
          Icon(Icons.videocam),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Ada Yang Mau Ditanyakan",
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                return _buildMessage(msg['text'], msg['isUser']);
              },
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: "Type here..."),
                ),
              ),
              IconButton(icon: const Icon(Icons.mic), onPressed: () {}),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}
