import 'package:akop_member_app/screens/request_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config.dart';

class PerksScreen extends StatelessWidget {
  const PerksScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint('Could not launch $launchUri');
      }
    } catch (e) {
      debugPrint('Error launching dialer: $e');
    }
  }

  void _showScheduleForm(BuildContext context) {
    // 1. Kuhanin ang messenger gamit ang MAIN context ng PerksScreen
    final rootMessenger = ScaffoldMessenger.of(context);
    
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => StatefulBuilder( // Ginamit ang modalContext para sa Navigator.pop
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 25,
              right: 25,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Request Teleconsult",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Tell us your concern and preferred schedule.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 25),

                  const Text("Reason for Consultation",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: "e.g. Fever, Headache, Requesting MedCert...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Preferred Date",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    enabled: !isLoading,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (pickedDate != null) {
                        dateController.text =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Select Date",
                      prefixIcon: const Icon(Icons.calendar_month, size: 20),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // SUBMIT BUTTON SECTION
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () async {  
                        if (reasonController.text.isEmpty || dateController.text.isEmpty) {
                        
                         _showTopNotification(context, "Please fill in all fields.", Colors.orange);
                        return; 
                        }
                        setModalState(() => isLoading = true);

                        try {
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          String? userJson = prefs.getString('user_session');

                          if (userJson != null) {
                            Map<String, dynamic> userData = json.decode(userJson);
                            String userId = userData['id'].toString();
                            String phone = userData['contact'] ?? ''; 

                            final response = await http.post(
                              Uri.parse("${AppConfig.baseUrl}/save_teleconsult.php"),
                              body: {
                                "user_id": userId,
                                "consultation_reason": reasonController.text,
                                "preferred_date": dateController.text,
                                "phone_number": phone,
                              },
                            ).timeout(const Duration(seconds: 10));  
                            debugPrint("SERVER RESPONSE: ${response.body}");
                            final result = json.decode(response.body);
                            if (result['status'] == 'success') {
                               
                              Navigator.pop(modalContext); 
                              _showTopNotification(
                                  context, 
                                  "Request submitted! We will contact you soon.", 
                                   Color.fromARGB(255, 36, 154, 25)
                                );

                              
                            } else {
                              throw Exception(result['message']);
                            }
                          } else {
                            throw Exception("User session not found.");
                          }
                        } catch (e) {
                          setModalState(() => isLoading = false);
                          setModalState(() => isLoading = false);
                          _showTopNotification(context, "Error: $e", Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 36, 154, 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text(
                            "SUBMIT REQUEST",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Member Perks"),
        backgroundColor: const Color.fromARGB(255, 36, 154, 25),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFeaturedPerk(context),
          const SizedBox(height: 25),
          const Text("Other Benefits",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              _buildPerkCard("E-Prescription", Icons.medication_liquid_rounded,
                  Colors.blue, "View history", () {}),
              _buildPerkCard("Pharmacy Disc.", Icons.local_pharmacy, Colors.red,
                  "Up to 10% off", () {}),
              _buildPerkCard(
                "Consult Requests", 
                Icons.pending_actions_rounded, 
                Colors.deepPurple, 
                "Track status", 
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RequestStatusScreen()),
                  );
                },
              ),
              _buildPerkCard("Med Certificate", Icons.verified_user_rounded,
                  Colors.orange, "Fast request", () {}),
            ],
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                debugPrint("Dialing hotline...");
                _makePhoneCall('09352427713');
              },
              borderRadius: BorderRadius.circular(20),
              child: _buildWidePerkCard("AnaKalusugan Hotline",
                  Icons.support_agent_rounded, Colors.teal, "Tap to call: 0935 242 7713"),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFeaturedPerk(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 36, 154, 25),
            Color.fromARGB(255, 80, 180, 70)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_services_rounded,
              color: Colors.white, size: 40),
          const SizedBox(height: 15),
          const Text("AnaKalusugan Teleconsult",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const Text("Talk to a doctor, for FREE.",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showScheduleForm(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text("Start Consult Now"),
          )
        ],
      ),
    );
  }

  Widget _buildPerkCard(
    String title, IconData icon, Color color, String sub, VoidCallback onTap) {
  return Material( 
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(18), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey[100]!), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11, 
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildWidePerkCard(
      String title, IconData icon, Color color, String sub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(sub,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.call, color: Colors.teal),
        ],
      ),
    );
  }

  void _showTopNotification(BuildContext context, String message, Color color) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10, // Sa itaas ng screen (below status bar)
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
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}