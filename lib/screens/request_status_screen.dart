import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config.dart';

class RequestStatusScreen extends StatefulWidget {
  const RequestStatusScreen({super.key});

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user_session');

      if (userJson != null) {
        Map<String, dynamic> userData = json.decode(userJson);
        // Ginagamit ang 'contact' gaya ng nasa code mo
        String userId = userData['contact'].toString();

        final response = await http.get(
          Uri.parse("${AppConfig.baseUrl}/get_my_requests.php?user_id=$userId"),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result['status'] == 'success') {
            setState(() {
              requests = result['data'];
              isLoading = false;
            });
          } else {
            throw Exception(result['message']);
          }
        } else {
          throw Exception("Server Error: ${response.statusCode}");
        }
      }
    } catch (e) {
      debugPrint("Error fetching requests: $e");
      if (mounted) {
        setState(() => isLoading = false);
        _showTopNotification(context, "Connection Error: Check your internet.", Colors.red);
      }
    }
  }

  // --- CANCEL REQUEST LOGIC ---
  Future<void> _cancelRequest(String requestId) async {
    // Isara ang modal bago simulan ang request
    Navigator.pop(context);
    
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/cancel_request.php"),
        body: {"id": requestId},
      ).timeout(const Duration(seconds: 10));

      final result = json.decode(response.body);
      
      if (result['status'] == 'success') {
        _showTopNotification(context, "Request cancelled successfully.", Colors.orange);
        _fetchRequests(); // Refresh the list
      } else {
        _showTopNotification(context, result['message'], Colors.red);
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showTopNotification(context, "Error: Could not cancel request.", Colors.red);
    }
  }

  // --- SHOW DETAILS MODAL ---
  void _showRequestDetails(Map<String, dynamic> req) {
    String status = req['status'] ?? 'Pending';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Request Details", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            _buildDetailRow("Reason", req['consultation_reason']),
            _buildDetailRow("Preferred Date", req['preferred_date']),
            _buildDetailRow("Status", status.toUpperCase(), 
                color: _getStatusColor(status), isBold: true),
            const SizedBox(height: 30),
            
            // LALABAS LANG ITONG BUTTON KUNG PENDING
            if (status.toLowerCase() == 'pending')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _cancelRequest(req['id'].toString()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("CANCEL REQUEST", 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
            child: Text(value, 
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.black87,
                )),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.orange;
    }
  }

  void _showTopNotification(BuildContext context, String message, Color color) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Consult Requests", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 36, 154, 25),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _fetchRequests, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: RefreshIndicator(
        color: const Color.fromARGB(255, 36, 154, 25),
        onRefresh: _fetchRequests,
        child: isLoading && requests.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : requests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      String status = req['status'] ?? 'Pending';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 1,
                        child: ListTile(
                          onTap: () => _showRequestDetails(req), // TAP TO SHOW DETAILS
                          contentPadding: const EdgeInsets.all(15),
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(status).withOpacity(0.1),
                            child: Icon(Icons.medical_services_outlined, color: _getStatusColor(status)),
                          ),
                          title: Text(req['consultation_reason'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Preferred: ${req['preferred_date']}"),
                                Text("ID: #${req['id']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            children: [
              Icon(Icons.assignment_late_outlined, size: 70, color: Colors.grey),
              SizedBox(height: 15),
              Text("No requests yet.", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}