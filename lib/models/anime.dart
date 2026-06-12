class Anime {
  final int id;
  final String title;
  final String image;
  final String? type;
  final int? episodeCount;
  final double? rating;
  final String? releaseDate;

  Anime({
    required this.id,
    required this.title,
    required this.image,
    this.type,
    this.episodeCount,
    this.rating,
    this.releaseDate,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'],
      title: json['title'],
      image: json['image'] ?? '',
      type: json['type'],
      episodeCount: json['episode_count'],
      rating: (json['rating'] as num?)?.toDouble(),
      releaseDate: json['release_date'],
    );
  }
}

class AnimeDetail {
  final int id;
  final String title;
  final String synopsis;
  final List<String> genres;
  final double? rating;
  final int episodeCount;
  final String? type;
  final String? status;
  final String coverImage;
  final String bannerImage;
  final List<Episode> episodes;

  AnimeDetail({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.genres,
    this.rating,
    required this.episodeCount,
    this.type,
    this.status,
    required this.coverImage,
    required this.bannerImage,
    required this.episodes,
  });

  factory AnimeDetail.fromJson(Map<String, dynamic> json) {
    return AnimeDetail(
      id: json['id'],
      title: json['title'],
      synopsis: json['synopsis'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      rating: (json['rating'] as num?)?.toDouble(),
      episodeCount: json['episode_count'] ?? 0,
      type: json['type'],
      status: json['status'],
      coverImage: json['cover_image'] ?? '',
      bannerImage: json['banner_image'] ?? '',
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Episode {
  final int id;
  final double number;
  final String? title;
  final String? thumbnail;

  Episode({
    required this.id,
    required this.number,
    this.title,
    this.thumbnail,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      number: (json['number'] as num).toDouble(),
      title: json['title'],
      thumbnail: json['thumbnail'],
    );
  }
}

class StreamInfo {
  final String streamUrl;
  final String type; // 'hls' o 'mp4'

  StreamInfo({required this.streamUrl, required this.type});

  factory StreamInfo.fromJson(Map<String, dynamic> json) {
    return StreamInfo(
      streamUrl: json['stream_url'],
      type: json['type'] ?? 'mp4',
    );
  }
}
