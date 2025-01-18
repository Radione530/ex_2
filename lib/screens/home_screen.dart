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
  List<dynamic> filteredMovies = [];
  bool isLoading = true;
  String errorMessage = '';

  String selectedSortOption = 'release_date';
  Set<String> selectedGenres = Set();
  String searchQuery = '';

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
          filteredMovies = List.from(movies);
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

  void applyFilters() {
    setState(() {
      filteredMovies = movies.where((movie) {
        if (searchQuery.isNotEmpty &&
            !movie['title'].toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
        }

        if (selectedGenres.isNotEmpty) {
          return selectedGenres
              .any((genre) => movie['genre_ids'].contains(genre));
        }
        return true;
      }).toList();

      switch (selectedSortOption) {
        case 'title':
          filteredMovies.sort((a, b) => a['title'].compareTo(b['title']));
          break;
        case 'release_date':
          filteredMovies
              .sort((a, b) => a['release_date'].compareTo(b['release_date']));
          break;
        case 'rating':
          filteredMovies
              .sort((a, b) => b['vote_average'].compareTo(a['vote_average']));
          break;
      }
    });
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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Search for a movie...',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (query) {
                                setState(() {
                                  searchQuery = query;
                                });
                                applyFilters();
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: selectedSortOption,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSortOption = newValue!;
                              });
                              applyFilters();
                            },
                            items: <String>['release_date', 'title', 'rating']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value == 'release_date'
                                    ? 'Release Date'
                                    : value == 'rating'
                                        ? 'Rating'
                                        : 'Title'),
                              );
                            }).toList(),
                          ),
                          SizedBox(width: 10),
                          FilterChip(
                            label: Text('Action'),
                            selected: selectedGenres.contains('Action'),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedGenres.add('Action');
                                } else {
                                  selectedGenres.remove('Action');
                                }
                              });
                              applyFilters();
                            },
                          ),
                          FilterChip(
                            label: Text('Comedy'),
                            selected: selectedGenres.contains('Comedy'),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedGenres.add('Comedy');
                                } else {
                                  selectedGenres.remove('Comedy');
                                }
                              });
                              applyFilters();
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredMovies.length,
                        itemBuilder: (context, index) {
                          final movie = filteredMovies[index];
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
                    ),
                  ],
                ),
    );
  }
}
