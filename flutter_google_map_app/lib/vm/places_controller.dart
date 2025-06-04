// controllers/places_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PlacesController extends GetxController {
  final RxSet<Marker> markers = <Marker>{}.obs;
  final String apiKey = ''; // 실제 API 키로 교체
  final RxBool isLoading = false.obs;

  Future<void> fetchPlaces({
    required LatLng location,
    required String placeType,
    int radius = 2000,
  }) async {
    isLoading.value = true;

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${location.latitude},${location.longitude}'
        '&radius=$radius'
        '&type=$placeType'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        Set<Marker> newMarkers = results.map((place) {
          final lat = place['geometry']['location']['lat'];
          final lng = place['geometry']['location']['lng'];
          final name = place['name'];
          final vicinity = place['vicinity'];

          return Marker(
            markerId: MarkerId(name),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: name,
              snippet: vicinity,
            ),
          );
        }).toSet();
        markers.value = newMarkers;
      } else {
        Get.snackbar('에러', 'Places API 오류: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('에러', '예외 발생: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
