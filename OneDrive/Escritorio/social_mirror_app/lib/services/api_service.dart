import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  final String baseUrl = "http://192.168.1.81:5000";

  Future<String> detectarEmocion(File imagen, String texto) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/emocion'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', imagen.path),
    );

    request.fields['texto'] = texto;

    var res = await request.send();
    var response = await http.Response.fromStream(res);

    var data = json.decode(response.body);

    return data['feedback'] ?? "Sin respuesta";
  }

  Future<Map<String, dynamic>> obtenerPregunta() async {
    final response = await http.get(Uri.parse("$baseUrl/pregunta"));
    return json.decode(response.body);
  }

  Future<void> siguientePregunta() async {
    await http.post(Uri.parse("$baseUrl/siguiente"));
  }
}