import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_browser/screens/settings_screen.dart';
import 'package:movie_browser/screens/favorites_screen.dart';
import 'package:movie_browser/screens/auth/login_screen.dart';
import 'package:movie_browser/screens/auth/register_screen.dart';
import 'package:movie_browser/screens/auth/user_screen.dart';
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
  Set<int> favoriteMovies = Set();

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
              .any((genre) => movie['genre_ids'].contains(int.parse(genre)));
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

  void toggleFavorite(int movieId) {
    setState(() {
      if (favoriteMovies.contains(movieId)) {
        favoriteMovies.remove(movieId);
      } else {
        favoriteMovies.add(movieId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.movie, size: 28),
            SizedBox(width: 10),
            Text(
              'Movie Browser',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'favorites') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(
                      allMovies: movies,
                      favoriteMovies: favoriteMovies,
                      onFavoritesChanged: (updatedFavorites) {
                        setState(() {
                          favoriteMovies = updatedFavorites;
                        });
                      },
                    ),
                  ),
                );
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              } else if (value == 'login') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } else if (value == 'register') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'favorites', child: Text('Favorites')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'login', child: Text('Login')),
              PopupMenuItem(value: 'register', child: Text('Register')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserScreen()),
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
                          SizedBox(width: 8),
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
                                child: Text(
                                  value == 'release_date'
                                      ? 'Release Date'
                                      : value == 'rating'
                                          ? 'Rating'
                                          : 'Title',
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredMovies.length,
                        itemBuilder: (context, index) {
                          final movie = filteredMovies[index];
                          final isFavorite =
                              favoriteMovies.contains(movie['id']);
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            child: ListTile(
                              leading: movie['poster_path'] != null
                                  ? Image.network(
                                      'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 70,
                                    )
                                  : Icon(Icons.image),
                              title: Text(movie['title']),
                              subtitle: Text(formatDate(movie['release_date'])),
                              trailing: IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                ),
                                onPressed: () => toggleFavorite(movie['id']),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
