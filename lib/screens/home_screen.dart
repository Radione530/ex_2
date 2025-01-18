import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_browser/screens/settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> movies = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final String apiKey = '9e4ece3e366d88dc4b9643cbe3b28cdb';
    final String url =
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=en-US&page=1';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          movies = data['results'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load movies: $e';
      });
    }
  }

  String formatDate(String releaseDate) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final DateTime date = DateTime.parse(releaseDate);
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.movie, size: 28),
            SizedBox(width: 10),
            Text(
              'Movie Browser',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return ListTile(
                      leading: movie['poster_path'] != null
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            )
                          : Icon(Icons.image),
                      title: Text(movie['title']),
                      subtitle: Text(formatDate(movie['release_date'])),
                    );
                  },
                ),
    );
  }
}
