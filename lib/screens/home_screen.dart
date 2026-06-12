import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, List<Anime>>> futureHome;

  @override
  void initState() {
    super.initState();
    futureHome = ApiService.getHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SavageAnime',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<Anime>>>(
        future: futureHome,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero slider con PageView
                  if (data['hero']!.isNotEmpty)
                    _HeroSlider(heroList: data['hero']!),
                  const SizedBox(height: 10),
                  _section('Ultimi episodi', data['latest_episodes']!),
                  _section('Popolari', data['popular']!),
                  _section('In corso', data['ongoing']!),
                  _section('Prossimamente', data['upcoming']!),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _section(String title, List<Anime> list) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final anime = list[index];
              return GestureDetector(
                onTap: () => _openDetail(anime.id),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(anime.image,
                            height: 130, width: 120, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 4),
                      Text(anime.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openDetail(int id) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => DetailScreen(animeId: id)));
  }
}

// Widget personalizzato per lo slider hero
class _HeroSlider extends StatefulWidget {
  final List<Anime> heroList;
  const _HeroSlider({required this.heroList});

  @override
  State<_HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<_HeroSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Auto-scroll ogni 4 secondi
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    if (_currentPage < widget.heroList.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.heroList.length,
            itemBuilder: (context, index) {
              final anime = widget.heroList[index];
              return GestureDetector(
                onTap: () {
                  // Naviga al dettaglio (bisogna passare la callback o ricostruire la navigazione)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailScreen(animeId: anime.id)),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(anime.image,
                        fit: BoxFit.cover, width: double.infinity),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(anime.title,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          if (anime.rating != null)
                            Text('⭐ ${anime.rating!.toStringAsFixed(1)}',
                                style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Indicatori a pallini
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.heroList.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.red : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
