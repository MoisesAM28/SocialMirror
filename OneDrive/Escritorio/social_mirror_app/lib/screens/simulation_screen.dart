import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';

class SimulationScreen extends StatefulWidget {
  final bool autoStart;

  const SimulationScreen({this.autoStart = false});

  @override
  _SimulationScreenState createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final ApiService api = ApiService();

  String _mensaje = "";
  String _pregunta = "Cargando pregunta...";
  File? _imagen;

  TextEditingController _controller = TextEditingController();

  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();

    _cargarPregunta();

    if (widget.autoStart) {
      Future.delayed(Duration(milliseconds: 500), () {
        _escuchar();
      });
    }
  }

  Future<void> _cargarPregunta() async {
    final data = await api.obtenerPregunta();

    setState(() {
      _pregunta = data["pregunta"];
    });
  }

  void _escuchar() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() => _isListening = true);

      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });

          if (result.finalResult && _controller.text.isNotEmpty) {
            _speech.stop();
            _isListening = false;

            _onSpeechFinished();
          }
        },
      );
    } else {
      setState(() => _isListening = false);
    }
  }

  Future<void> _onSpeechFinished() async {
    setState(() {
      _mensaje = "Tomando foto...";
    });

    await _tomarFoto();
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagen = File(pickedFile.path);
        _mensaje = "Analizando emoción...";
      });

      String respuesta = await api.detectarEmocion(
        _imagen!,
        _controller.text,
      );

      await api.siguientePregunta();
      await _cargarPregunta();

      setState(() {
        _mensaje = respuesta;
      });
    }
  }

  @override

Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// 🧠 PREGUNTA (BONITA)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _pregunta,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 📷 IMAGEN BONITA
              Container(
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: _imagen != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _imagen!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.white70,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              /// ✍️ INPUT BONITO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Habla o escribe...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🎤 BOTÓN MODERNO
              GestureDetector(
                onTap: _escuchar,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? Colors.redAccent
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening
                            ? Colors.white
                            : Colors.deepPurple,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isListening ? "Escuchando..." : "Hablar",
                        style: TextStyle(
                          color: _isListening
                              ? Colors.white
                              : Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// 💬 RESPUESTA BONITA
              if (_mensaje.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}
}
