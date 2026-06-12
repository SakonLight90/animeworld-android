import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';

class PlayerScreen extends StatefulWidget {
  final int episodeId;
  final String episodeTitle;
  const PlayerScreen(
      {super.key, required this.episodeId, required this.episodeTitle});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late Future<VideoPlayerController> _controllerFuture;
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controllerFuture = _initPlayer();
    // Imposta subito landscape + fullscreen
    _setLandscapeMode();
  }

  @override
  void dispose() {
    _setPortraitMode(); // ripristina orientamento e barre
    _controller?.dispose();
    super.dispose();
  }

  Future<VideoPlayerController> _initPlayer() async {
    try {
      final streamInfo = await ApiService.getStreamUrl(widget.episodeId);
      final uri = Uri.parse(streamInfo.streamUrl);
      final controller = VideoPlayerController.networkUrl(uri);
      await controller.initialize();
      _controller = controller;
      _isLoading = false;
      controller.play();
      return controller;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Impossibile riprodurre l\'episodio: $e';
      rethrow;
    }
  }

  void _setLandscapeMode() {
    // Forza orientamento landscape (entrambi i lati per ruotare il dispositivo)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Nasconde barra di stato e barra di navigazione (fullscreen)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _setPortraitMode() {
    // Ripristina orientamento automatico (verticale)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Mostra di nuovo le barre di sistema
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    // Quando si preme il tasto indietro, ripristiniamo l'orientamento
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, _) {
        if (didPop) {
          _setPortraitMode();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder<VideoPlayerController>(
          future: _controllerFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData && _controller != null) {
              return Stack(
                children: [
                  // Video a schermo intero
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                  // Controlli personalizzati (play/pausa)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VideoProgressIndicator(_controller!,
                              allowScrubbing: true),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 48,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controller!.value.isPlaying
                                        ? _controller!.pause()
                                        : _controller!.play();
                                  });
                                },
                              ),
                              // Pulsante per chiudere il player (torna indietro)
                              IconButton(
                                icon: const Icon(Icons.fullscreen_exit,
                                    color: Colors.white),
                                onPressed: () {
                                  _setPortraitMode();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError || _errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _errorMessage ?? 'Errore sconosciuto',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
