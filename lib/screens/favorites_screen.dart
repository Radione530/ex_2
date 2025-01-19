import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FavoritesScreen extends StatefulWidget {
  final List<dynamic> allMovies;
  final Set<int> favoriteMovies;
  final Function(Set<int>) onFavoritesChanged;

  FavoritesScreen({
    required this.allMovies,
    required this.favoriteMovies,
    required this.onFavoritesChanged,
  });

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> filteredMovies = [];
  String selectedSortOption = 'release_date';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    applyFilters();
  }

  void applyFilters() {
    setState(() {
      filteredMovies = widget.allMovies.where((movie) {
        if (!widget.favoriteMovies.contains(movie['id'])) return false;
        if (searchQuery.isNotEmpty &&
            !movie['title'].toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
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
      if (widget.favoriteMovies.contains(movieId)) {
        widget.favoriteMovies.remove(movieId);
      } else {
        widget.favoriteMovies.add(movieId);
      }
      widget.onFavoritesChanged(widget.favoriteMovies);
      applyFilters();
    });
  }

  String formatDate(String? releaseDate) {
    if (releaseDate == null || releaseDate.isEmpty) {
      return 'Unknown release date';
    }
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final DateTime date = DateTime.parse(releaseDate);
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: isDarkMode ? Colors.brown[900] : Colors.brown[200],
      ),
      body: Container(
        color: isDarkMode ? Colors.brown[800] : Colors.brown[100],
        child: Column(
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
                        fillColor:
                            isDarkMode ? Colors.brown[700] : Colors.white,
                        filled: true,
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
                    dropdownColor:
                        isDarkMode ? Colors.brown[700] : Colors.white,
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
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredMovies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 80,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.brown[600]),
                          SizedBox(height: 10),
                          Text(
                            'No favorite movies found.',
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  isDarkMode ? Colors.white : Colors.brown[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredMovies.length,
                      itemBuilder: (context, index) {
                        final movie = filteredMovies[index];
                        return Card(
                          color:
                              isDarkMode ? Colors.brown[700] : Colors.brown[50],
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            leading: movie['poster_path'] != null
                                ? Image.network(
                                    'https://image.tmdb.org/t/p/w200${movie['poster_path']}',
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                  )
                                : Icon(Icons.image, color: Colors.grey),
                            title: Text(
                              movie['title'],
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.brown[900],
                              ),
                            ),
                            subtitle: Text(
                              formatDate(movie['release_date']),
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.brown[700],
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.red,
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
      ),
    );
  }
}
