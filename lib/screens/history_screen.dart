import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;
import '../core/config.dart';

class HistoryScreen extends StatefulWidget {
  final String userId;
  const HistoryScreen({super.key, required this.userId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = fetchHistory();
  }

  Future<List<dynamic>> fetchHistory() async {
    dev.log("Fetching history for user_id: ${widget.userId}", name: "HISTORY_FETCH");
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/get_history.php?user_id=${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        }
      }
    } catch (e) {
      dev.log("History Fetch Error: $e");
    }
    return [];
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _historyFuture = fetchHistory();
    });
    await _historyFuture;
  }

  // --- FUNCTION PARA SA MODAL DETAILS ---
  void _showDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Mahalaga ito dahil marami tayong fields
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85, // 85% ng screen height
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 50, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              Text(
                "Consultation Detail",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 36, 154, 25),
                ),
              ),
              const SizedBox(height: 5),
              Text("Control ID: ${item['p_ctrlID'] ?? 'N/A'}", style: const TextStyle(color: Colors.grey)),
              const Divider(height: 30),
              
              // Scrollable Content area
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  children: [
                    _buildDetailRow("Patient Name", item['p_patient']),
                    _buildDetailRow("Chief Complaint", item['p_complaint']),
                    _buildDetailRow("Medical History", item['p_history']),
                    _buildDetailRow("Current Medication", item['p_medication']),
                    _buildDetailRow("Prescribed Medicine", item['p_med']),
                    _buildDetailRow("Other Notes", item['p_others']),
                    _buildDetailRow("Transfer Comment", item['p_trasfer_comment']),
                    
                    const SizedBox(height: 15),
                    const Text("Status:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (item['status'] == 'Completed') ? Colors.green[100] : Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['status'] ?? 'Pending',
                          style: TextStyle(
                            color: (item['status'] == 'Completed') ? Colors.green[900] : Colors.orange[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              
              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 36, 154, 25),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Done", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper Widget para sa bawat row ng impormasyon
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            (value == null || value.isEmpty) ? "None" : value,
            style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[200], thickness: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consultation History"),
        backgroundColor: const Color.fromARGB(255, 36, 154, 25),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text("No history found.")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 36, 154, 25),
                      child: Icon(Icons.medical_services, color: Colors.white),
                    ),
                    title: Text(item['p_patient'] ?? 'No Name', // Pinalitan ng Patient name ang title
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['created_at'] ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showDetails(context, item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}