import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../core/config.dart';

// 1. DATA MODEL PARA SA NEWS (Pareho pa rin)
class NewsArticle {
  final int id;
  final String title;
  final String content;
  final String category;
  final String author;
  final DateTime publishedDate;
  final String imageUrl;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.author,
    required this.publishedDate,
    required this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: int.parse(json['news_id']),
      title: json['headline_title'] ?? '',
      content: json['content_body'] ?? '',
      category: json['category_tag'] ?? '',
      author: json['author_source'] ?? '',
      publishedDate: DateTime.parse(json['date_time_published']),
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Health", "Announcements", "Maritime", "System"];
  late Future<List<NewsArticle>> _newsFuture;
  
  
  final TextEditingController _searchController = TextEditingController(); 
  String _searchQuery = ""; 
  List<NewsArticle> _allNews = []; 

  @override
  void initState() {
    super.initState();
    _newsFuture = fetchNews();
  }

  @override
  void dispose() {
    _searchController.dispose(); 
    super.dispose();
  }

  
  Future<void> _onRefresh() async {
    setState(() {
      _searchController.clear(); 
      _searchQuery = "";
      _newsFuture = fetchNews();
    });
    await _newsFuture;
  }

 
  Future<List<NewsArticle>> fetchNews() async {
    try {
     final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/get_news.php"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _allNews = data.map((item) => NewsArticle.fromJson(item)).toList(); 
        return _allNews;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

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
              controller: _searchController, // I-connect ang controller
              onChanged: (value) {
                // I-update ang search query at i-refresh ang UI kapag nagbago ang input
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search AK news...",
                prefixIcon: const Icon(Icons.search),
                // Magdagdag ng clear button kung may laman ang search bar
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = "";
                        });
                      },
                    )
                  : null,
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
                    onSelected: (bool value) {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                    selectedColor: const Color.fromARGB(255, 36, 154, 25).withOpacity(0.2),
                    checkmarkColor: const Color.fromARGB(255, 36, 154, 25),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 3. NEWS LIST (GAMIT ANG FUTUREBUILDER AT REFRESHINDICATOR)
          Expanded(
            child: FutureBuilder<List<NewsArticle>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No news available.'),
                  );
                } else {
                  // --- FILTER LOGIC ---
                  // Kunin ang data mula sa snapshot
                  List<NewsArticle> newsList = snapshot.data!;
                  
                  // Una, i-filter ayon sa kategorya
                  if (selectedCategory != "All") {
                    newsList = newsList.where((news) => news.category == selectedCategory).toList();
                  }
                  
                  // Pangalawa, i-filter ayon sa search query (pamagat o nilalaman)
                  if (_searchQuery.isNotEmpty) {
                    newsList = newsList.where((news) => 
                      news.title.toLowerCase().contains(_searchQuery) || 
                      news.content.toLowerCase().contains(_searchQuery)
                    ).toList();
                  }

                  // Ipakita ang "No results found" kung walang tumugma sa filter
                  if (newsList.isEmpty) {
                    return const Center(
                      child: Text('No results found for your search.'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color.fromARGB(255, 36, 154, 25),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final news = newsList[index];
                        return _buildCompactNewsTile(news);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- _buildCompactNewsTile at _showNewsDetails ay pareho pa rin ---
  Widget _buildCompactNewsTile(NewsArticle news) {
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(news.publishedDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => _showNewsDetails(context, news),
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
                  Text(news.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text("$formattedDate • ${news.category}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(news.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewsDetails(BuildContext context, NewsArticle news) {
    final String formattedDate = DateFormat('MMMM dd, yyyy').format(news.publishedDate);

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
            Text(news.category.toUpperCase(), style: const TextStyle(color: Color.fromARGB(255, 36, 154, 25), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            Text(news.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
            const SizedBox(height: 10),
            Text("Published on $formattedDate by ${news.author}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 40),
            Expanded(
              child: SingleChildScrollView(
                child: Text(news.content, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
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