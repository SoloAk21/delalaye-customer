import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../domain/apiauthhelpers/apiauth.dart';
import '../model/broker_info_model.dart';

class PlacePickerApiService {
  final String apiKey;
  PlacePickerApiService(this.apiKey);

  Future<List<BrokerInfo>> fetchBrokers({
    required double latitude,
    required double longitude,
    required int serviceId,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final url =
        '${ApiAuthHelper.baseURL}/api/broker/filter?serviceId=$serviceId&latitude=$latitude&longitude=$longitude';
    var token = prefs.getString('token') ?? '';
    var headers = {'x-auth-token': token};
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => BrokerInfo.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch brokers");
    }
  }

  Future<String?> getPlaceId(double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        return data['results'][0]['place_id'];
      }
    }
    return null;
  }

  ///to get the palceId by using latitude and longitude
  Future<String?> searchPlace(double latitude, double longitude) async {
    String endpoint =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${apiKey}';
    http.Response response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        // Extract place ID from the first result
        return data['results'][0]['place_id'];
      }
    }
    return null;
  }
}
