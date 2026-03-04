import 'package:akop_member_app/screens/history_screen.dart';
import 'package:akop_member_app/screens/login_screen.dart';
import 'package:akop_member_app/screens/profile_screen.dart';
import 'package:akop_member_app/screens/news_screen.dart';
import 'package:akop_member_app/screens/perks_screen.dart';
 
 
import 'package:flutter/material.dart';

class HomeDashboard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomeDashboard({super.key, required this.userData});
  
 
  void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Sigurado ka bang gusto mong mag-logout sa AKOP CARE?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              // I-clear ang stack at bumalik sa LoginScreen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // Tinatanggal lahat ng previous screens (History, etc.)
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    // Kunin natin ang mga detalye mula sa login response
    final String fullName = userData['full_name'] ?? 'User';
    final String rank = userData['rank'] ?? 'Member';

    final String userId = userData['contact'].toString(); 
  
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Care Dashboard"),
        backgroundColor:const Color.fromARGB(255, 36, 154, 25),

        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          )
        ],

        
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:  Color.fromARGB(255, 36, 154, 25),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rank: $rank",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- MENU TILES SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                 _buildMenuTile(
                    context,
                    title: "History",
                    icon: Icons.history_rounded,
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen(userId: userId)),
                    ),
                  ),
                 _buildMenuTile(
                    context, 
                    title: "Perks", 
                    icon: Icons.card_giftcard, 
                    color: const Color.fromARGB(255, 36, 154, 25), // Ginawa nating terno sa brand green mo
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PerksScreen()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    context, 
                    title: "News Corner", 
                    icon: Icons.newspaper, 
                    color: Colors.blue, // Pwede mong gawing Green din para terno sa theme mo
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewsScreen()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    context, 
                    title: "Profile", 
                    icon: Icons.settings, 
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userData: userData),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            
            // --- RECENT LOGS SECTION (Preview) ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text("Teleconsult Completed"),
              subtitle: Text("March 03, 2026 - Dr. Smith"),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget para sa mga Buttons
  Widget _buildMenuTile(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}