import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FavoritesScreen extends StatefulWidget {
  final List<dynamic> allMovies;
  final Set<int> favoriteMovies;
  final Function(Set<int>) onFavoritesChanged;

  FavoritesScreen(
      {required this.allMovies,
      required this.favoriteMovies,
      required this.onFavoritesChanged});

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
        if (!widget.favoriteMovies.contains(movie['id'])) {
          return false;
        }
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

  String formatDate(String releaseDate) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final DateTime date = DateTime.parse(releaseDate);
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: Column(
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
              ],
            ),
          ),
          Expanded(
            child: filteredMovies.isEmpty
                ? Center(child: Text('No favorite movies found.'))
                : ListView.builder(
                    itemCount: filteredMovies.length,
                    itemBuilder: (context, index) {
                      final movie = filteredMovies[index];
                      final isFavorite =
                          widget.favoriteMovies.contains(movie['id']);
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
                        trailing: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () => toggleFavorite(movie['id']),
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
