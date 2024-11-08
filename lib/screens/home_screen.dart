import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // API URL
  final String apiUrl = 'https://api.jikan.moe/v4/anime'; // Jikan API for list of animes

  // fetch (GET call) anime data with try-catch
  Future<List<dynamic>> getAnimeJSON() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['data']; 
      } else {
        throw Exception('Failed to load anime');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
        backgroundColor: const Color.fromARGB(255, 165, 165, 165),
      ),
      body: FutureBuilder<List<dynamic>>(
        // setup the URL for your API here
        future: getAnimeJSON(), // calling getAnimeJSON to fetch anime data
        builder: (context, snapshot) {
          // Consider 3 cases here
          
          // when the process is ongoing
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // when the process is completed:
          // successful
          if (snapshot.hasData) {
            var animeList = snapshot.data!;

            // Use the library here
            return ExpandedTileList.builder(
              itemCount: animeList.length,
              itemBuilder: (context, index, controller) {
                var anime = animeList[index];
                String imageUrl = anime['images']['jpg']['image_url'] ?? ''; // if there’s no image_url, return to an empty string
                String title = anime['title'] ?? 'Unknown Title';
                String synopsis = anime['synopsis'] ?? 'No synopsis available';
                String year = anime['year']?.toString() ?? 'Unknown Year';
                String episodes = anime['episodes']?.toString() ?? 'Unknown Episodes';
                String genres = (anime['genres'] != null)
                    ? anime['genres'].map((genre) => genre['name']).join(', ') // for multiple genres associated with one anime
                    : 'No genres available';
                String status = anime['status'] ?? 'Unknown Status';
                
                // return ExpandedTile with details
                return ExpandedTile(
                  theme: ExpandedTileThemeData(
                    headerColor: const Color.fromARGB(255, 255, 255, 255),
                    headerPadding: EdgeInsets.all(12),
                    contentBackgroundColor: const Color.fromARGB(255, 228, 228, 228),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  controller: controller,
                  // to only show image and title
                  title: Row(
                    children: [
                      imageUrl.isNotEmpty
                          ? ClipRRect( 
                            // for rounded image corners
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                height: 100,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.image_not_supported, size: 50), // if empty, use image_not_supported icon
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    // to show other details
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Synopsis:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        synopsis,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Year Released: $year',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Episodes: $episodes',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Genres: $genres',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Status: $status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          // error
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        },
      ),
    );
  }
}
