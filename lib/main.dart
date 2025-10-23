import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(DailyNewsApp());
}

class DailyNewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily News',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: SplashScreen(),
    );
  }
}

//
// 🟦 Splash Screen
//
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NewsHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DAILY NEWS',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 25),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

//
// 📰 Home Page
//
class NewsHomePage extends StatefulWidget {
  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  final String apiKey = '312d55f77c4a40469d80f9b66c424c42'; // API key
  List articles = [];
  String selectedCategory = 'general';
  String query = '';
  bool isLoading = true;

  final List<String> categories = [
    'general',
    'technology',
    'business',
    'sports',
    'entertainment',
    'health',
    'science',
  ];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() => isLoading = true);
    String url =
        'https://newsapi.org/v2/top-headlines?country=us&category=$selectedCategory&apiKey=$apiKey';
    if (query.isNotEmpty) {
      url =
          'https://newsapi.org/v2/everything?q=$query&language=en&apiKey=$apiKey';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        articles = json.decode(response.body)['articles'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load news')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DAILY NEWS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 3,
        shadowColor: Colors.grey[300],
        backgroundColor: const Color.fromARGB(255, 172, 174, 176),
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: const Color.fromARGB(255, 0, 0, 0)),
            onPressed: fetchNews,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                hintText: 'Search news...',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                setState(() => query = value);
                fetchNews();
              },
            ),
          ),

          // 🏷️ Category Chips
          Container(
            height: 45,
            margin: EdgeInsets.only(bottom: 5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                String category = categories[index];
                bool isSelected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ChoiceChip(
                    label: Text(
                      category[0].toUpperCase() + category.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                        query = '';
                      });
                      fetchNews();
                    },
                    backgroundColor: Colors.grey[200],
                  ),
                );
              },
            ),
          ),

          // 📰 News Articles
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchNews,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        final imageUrl = article['urlToImage'] ??
                            'https://via.placeholder.com/400x200';
                        final title = article['title'] ?? 'No title available';
                        final description =
                            article['description'] ?? 'No description available';

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shadowColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NewsDetailPage(article: article),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey[200],
                                    height: 200,
                                    child: Icon(Icons.image, size: 60),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        description,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

//
// 📄 Article Details Page
//
class NewsDetailPage extends StatelessWidget {
  final Map article;
  const NewsDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        article['urlToImage'] ?? 'https://via.placeholder.com/400x200';
    final title = article['title'] ?? 'No title available';
    final content = article['content'] ?? 'No content available';
    final sourceUrl = article['url'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Article Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(sourceUrl))) {
                  await launchUrl(Uri.parse(sourceUrl),
                      mode: LaunchMode.externalApplication);
                }
              },
              icon: Icon(Icons.open_in_browser),
              label: Text('Read Full Article'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
