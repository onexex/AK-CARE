import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
          
          _buildFeaturedPerk(),

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
              _buildPerkCard("E-Prescription", Icons.medication_liquid_rounded, Colors.blue, "View history", () {}),
              _buildPerkCard("Pharmacy Disc.", Icons.local_pharmacy, Colors.red, "Up to 10% off", () {}),
              _buildPerkCard("Lab Partners", Icons.biotech_rounded, Colors.purple, "Discounted rates", () {}),
              _buildPerkCard("Med Certificate", Icons.verified_user_rounded, Colors.orange, "Fast request", () {}),
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
              splashColor: Colors.teal.withOpacity(0.1),
              child: _buildWidePerkCard(
                "AnaKalusugan Hotline", 
                Icons.support_agent_rounded, 
                Colors.teal, 
                "Tap to call: 0935 242 7713"
              ),
            ),
          ),
          const SizedBox(height: 30), 
        ],
      ),
    );
  }

  Widget _buildFeaturedPerk() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 36, 154, 25), Color.fromARGB(255, 80, 180, 70)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_services_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 15),
          const Text("AnaKalusugan Teleconsult", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Talk to a doctor, for FREE.", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {},
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.white, 
          //     foregroundColor: Colors.green[800], 
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          //   ),
          //   child: const Text("Start Consult Now"),
          // )
        ],
      ),
    );
  }

  Widget _buildPerkCard(String title, IconData icon, Color color, String sub, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildWidePerkCard(String title, IconData icon, Color color, String sub) {
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(sub, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.call, color: Colors.teal),
        ],
      ),
    );
  }
}