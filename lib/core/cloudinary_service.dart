import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({required this.cloudName, this.uploadPreset = 'hostel_mochileros'});

  Future<String> uploadImage(String base64Image) async {
    try {
      print('📤 Subiendo imagen a Cloudinary...');
      
      // Extraer solo la parte base64 (sin el prefix data:image/...)
      String cleanBase64 = base64Image;
      if (base64Image.contains(',')) {
        cleanBase64 = base64Image.split(',').last;
      }

      // Crear form data para la subida
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromString(
          'file',
          'data:image/jpeg;base64,$cleanBase64',
        ));

      print('🌐 Enviando solicitud a Cloudinary...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        final imageUrl = jsonResponse['secure_url'];
        print('✅ Imagen subida exitosamente: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Error de Cloudinary: ${jsonResponse['error']['message']}');
      }
    } catch (e) {
      print('❌ Error subiendo imagen a Cloudinary: $e');
      throw Exception('Error al subir imagen: $e');
    }
  }
}