import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/models/brandingModel/branding_model.dart';
import 'network_info.dart';

class BrandingApiService {
  final NetworkInfo networkInfo;

  // Update this to match your actual deployment/server URL
  final String baseUrl = 'http://192.168.1.45:5000/api/branding';

  BrandingApiService(this.networkInfo);

  /// Fetches branding configuration from backend
  Future<Branding> fetchBranding() async {
    // Check internet connection first
    if (await networkInfo.isConnected()) {
      try {
        final response = await http.get(Uri.parse(baseUrl));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          return Branding.fromJson(jsonData);
        } else {
          throw Exception(
              'Failed to load branding data: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching branding: $e');
      }
    } else {
      throw Exception('No internet connection');
    }
  }
}
