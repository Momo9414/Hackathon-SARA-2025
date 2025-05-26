import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('analysis_history');
    if (historyString != null) {
      final List<dynamic> decoded = jsonDecode(historyString);
      setState(() {
        _history = decoded.cast<Map<String, dynamic>>();
      });
    }
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Image.file(
          File(item['imagePath']),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(item['diseaseName']),
        subtitle: Text(
          "${(item['confidence'] * 100).toStringAsFixed(1)}% • ${item['date']}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 120,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/image_input');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Commencer une analyse',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "🕓 Historique des analyses",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _history.isEmpty
                    ? const Center(
                        child: Text("Aucun historique pour l’instant."))
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(
                              _history.reversed.toList()[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
