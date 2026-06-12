import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/api_service.dart';
import 'player_screen.dart';

class DetailScreen extends StatefulWidget {
  final int animeId;
  const DetailScreen({super.key, required this.animeId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<AnimeDetail> futureDetail;

  @override
  void initState() {
    super.initState();
    futureDetail = ApiService.getAnimeDetail(widget.animeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dettaglio'),
      ),
      body: FutureBuilder<AnimeDetail>(
        future: futureDetail,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final anime = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title:
                        Text(anime.title, style: const TextStyle(fontSize: 16)),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                            anime.bannerImage.isNotEmpty
                                ? anime.bannerImage
                                : anime.coverImage,
                            fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (anime.rating != null)
                          Text(
                              '⭐ ${anime.rating!.toStringAsFixed(1)} · ${anime.type ?? ""} · ${anime.status ?? ""}',
                              style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        if (anime.genres.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            children: anime.genres
                                .map((g) => Chip(label: Text(g)))
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        const Text('Sinossi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(anime.synopsis,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 20),
                        const Text('Episodi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: anime.episodes.length,
                          itemBuilder: (context, index) {
                            final ep = anime.episodes[index];
                            return ListTile(
                              leading: ep.thumbnail != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(ep.thumbnail!,
                                          width: 80,
                                          height: 45,
                                          fit: BoxFit.cover),
                                    )
                                  : null,
                              title: Text(
                                  'Ep. ${ep.number}${ep.title != null ? ' - ${ep.title}' : ''}'),
                              trailing: const Icon(Icons.play_arrow),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlayerScreen(
                                        episodeId: ep.id,
                                        episodeTitle: 'Ep. ${ep.number}'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            // Mostra l'errore in modo chiaro con possibilità di tornare indietro
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Errore: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Torna indietro'),
                    ),
                  ],
                ),
              ),
            );
          }
          // caricamento
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
