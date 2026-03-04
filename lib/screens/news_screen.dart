import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Health", "Announcements", "Maritime", "System"];

  // DUMMY DATA PARA SA TESTING
  final List<Map<String, String>> dummyNews = [
    {
      "title": "New Teleconsultation Schedule for March 2026",
      "date": "March 04, 2026",
      "category": "Announcements",
      "content": "Good news! We have added more slots for night-shift seafarers. Our doctors are now available from 8:00 PM to 2:00 AM to cater to those on duty. Please book your slots at least 24 hours in advance through the portal.",
      "author": "Admin"
    },
    {
      "title": "Maritime Health Tips: Staying Fit on Board",
      "date": "March 02, 2026",
      "category": "Health",
      "content": "Maintaining a healthy diet while at sea is crucial for long-term health. Avoid excessive sodium and stay hydrated. We recommend at least 15 minutes of stretching daily to avoid back pain during long voyages.",
      "author": "Dr. Santos"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("News Corner"),
        backgroundColor: const Color.fromARGB(255, 36, 154, 25),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search AK news...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          // 2. CATEGORY FILTERS
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedCategory == categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: FilterChip(
                    label: Text(categories[index]),
                    selected: isSelected,
                    onSelected: (bool value) => setState(() => selectedCategory = categories[index]),
                    selectedColor: const Color.fromARGB(255, 36, 154, 25).withOpacity(0.2),
                    checkmarkColor: const Color.fromARGB(255, 36, 154, 25),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 3. NEWS LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dummyNews.length,
              itemBuilder: (context, index) {
                final news = dummyNews[index];
                return _buildCompactNewsTile(news);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPACT TILE NA CLICKABLE ---
  Widget _buildCompactNewsTile(Map<String, String> news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => _showNewsDetails(context, news), // DITO ANG CLICKABLE LOGIC
        borderRadius: BorderRadius.circular(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.article_rounded, color: Color.fromARGB(255, 36, 154, 25), size: 40),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(news['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text("${news['date']} • ${news['category']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(news['content']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL PARA SA DETALYE NG NEWS ---
  void _showNewsDetails(BuildContext context, Map<String, String> news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 25),
            Text(news['category']!.toUpperCase(), style: const TextStyle(color: Color.fromARGB(255, 36, 154, 25), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            Text(news['title']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
            const SizedBox(height: 10),
            Text("Published on ${news['date']} by ${news['author']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 40),
            Expanded(
              child: SingleChildScrollView(
                child: Text(news['content']!, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 36, 154, 25), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Back to News", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}