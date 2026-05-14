import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class Announcement {
  final String title;
  final String content;

  Announcement({required this.title, required this.content});

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}

class Movie {
  final String title;
  final String genre;

  Movie({required this.title, required this.genre});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
      ),
      home: const MyHomePage(title: 'Welcome to St. Augustine'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Announcement>> _announcements;
  int _currentIndex = 0;

  final List<Movie> _dummyMovies = [
    Movie(title: 'Ocean Adventure', genre: 'Adventure'),
    Movie(title: 'Midnight Melody', genre: 'Drama'),
    Movie(title: 'Rocket Riders', genre: 'Sci-Fi'),
    Movie(title: 'The Great Escape', genre: 'Action'),
  ];

  @override
  void initState() {
    super.initState();
    _announcements = _fetchAnnouncements();
  }

  Future<List<Announcement>> _fetchAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('https://getannouncementemma-4vxvhm267q-uc.a.run.app'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        print('Decoded data type: ${jsonData.runtimeType}');

        List<dynamic> announcements = [];
        if (jsonData is List) {
          announcements = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('announcements')) {
          announcements = jsonData['announcements'] as List<dynamic>;
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          announcements = jsonData['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected JSON structure: $jsonData');
        }

        return announcements
            .map((item) => Announcement.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching announcements: $e');
      throw Exception('Error: $e');
    }
  }

  Widget _buildCurrentTabBody() {
    return _currentIndex == 0 ? _buildHomeTab() : _buildMoviesTab();
  }

  Widget _buildHomeTab() {
    return FutureBuilder<List<Announcement>>(
      future: _announcements,
      builder: (context, snapshot) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Announcement Board',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Error loading announcements:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (snapshot.hasData)
                    ...snapshot.data!.map((announcement) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red.shade900,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement.title,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                            Text(
                              announcement.content,
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    const Text('No announcements', textAlign: TextAlign.left),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoviesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movies',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _dummyMovies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final movie = _dummyMovies[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade900.withOpacity(0.8),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movie.genre,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.movie, color: Colors.red.shade900),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        toolbarHeight: 120,
        centerTitle: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 22),
              ),
              const Text(
                'today is a beautiful day 1',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'February 19, 2026',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      body: _buildCurrentTabBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
        ],
      ),
    );
  }
}
