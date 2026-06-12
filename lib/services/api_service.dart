import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class ApiService {
  static const String baseUrl = 'https://savageghost.duckdns.org/api/v2';

  static Future<Map<String, List<Anime>>> getHome() async {
    final response = await http.get(Uri.parse('$baseUrl/home'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'hero': (data['hero'] as List).map((e) => Anime.fromJson(e)).toList(),
        'latest_episodes': (data['latest_episodes'] as List)
            .map((e) => Anime.fromJson(e))
            .toList(),
        'popular':
            (data['popular'] as List).map((e) => Anime.fromJson(e)).toList(),
        'ongoing':
            (data['ongoing'] as List).map((e) => Anime.fromJson(e)).toList(),
        'upcoming':
            (data['upcoming'] as List).map((e) => Anime.fromJson(e)).toList(),
      };
    } else {
      throw Exception('Errore caricamento home');
    }
  }

  static Future<AnimeDetail> getAnimeDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/anime/$id'));
    if (response.statusCode == 200) {
      return AnimeDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('Anime non trovato');
    }
  }

  static Future<List<Anime>> search(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Anime.fromJson(e)).toList();
    } else {
      throw Exception('Errore ricerca');
    }
  }

  static Future<StreamInfo> getStreamUrl(int episodeId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/stream?episode_id=$episodeId'));
    if (response.statusCode == 200) {
      return StreamInfo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Streaming non disponibile');
    }
  }
}
