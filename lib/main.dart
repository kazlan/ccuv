import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const CCuVApp());

class CCuVApp extends StatelessWidget {
  const CCuVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCuV Radio',
      // Quitamos la cinta de "Debug"
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instancia del reproductor de audio
  late AudioPlayer _player;

  // URL del stream de música online.
  // **REEMPLAZA ESTA URL POR LA DE TU RADIO**
  final String _streamUrl = "https://edge.mixlr.com/channel/dlyio";

  // Variable para controlar el estado de reproducción
  bool _isPlaying = false;
  // Variable para saber si el stream está cargando
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() async {
    try {
      // Configuramos la URL del stream
      await _player.setUrl(_streamUrl);

      // Nos suscribimos a los cambios de estado del reproductor
      _player.playerStateStream.listen((state) {
        // Actualizamos nuestro estado _isPlaying según el estado del reproductor
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            // Dejamos de mostrar el indicador de carga cuando empieza a sonar o se detiene
            if (state.processingState == ProcessingState.ready ||
                state.processingState == ProcessingState.completed) {
              _isLoading = false;
            }
          });
        }
      });
    } catch (e) {
      // Manejar error de carga de URL
      print("Error al cargar la URL del stream: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Aquí podrías mostrar un mensaje al usuario
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _player.pause();
    } else {
      // Mostramos el indicador de carga y empezamos la reproducción
      setState(() {
        _isLoading = true;
      });
      _player.play();
    }
  }

  @override
  void dispose() {
    // Es muy importante liberar los recursos del reproductor al cerrar la pantalla
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determinamos qué imagen de fondo usar
    final String backgroundImage = _isPlaying
        ? 'assets/images/playing_bg.png'
        : 'assets/images/stopped_bg.png';

    return Scaffold(
      body: Container(
        // El widget Container nos permite poner una imagen de fondo
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            // La imagen cubrirá toda la pantalla
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Añadimos una capa oscura semitransparente para que el texto y los iconos resalten
          color: Colors.black.withOpacity(0.0),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título de la App
                  const Text(
                    'CCuV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tu música, tu momento',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Mostramos el botón o el indicador de carga
                  _buildControlButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton() {
    if (_isLoading) {
      // Si está cargando, mostramos un círculo de progreso
      return const SizedBox(
        width: 80,
        height: 80,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 5.0,
        ),
      );
    }
    // Si no está cargando, mostramos el botón de Play/Pause
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.deepPurple.withOpacity(0.5),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(
          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 60.0,
        ),
      ),
    );
  }
}
