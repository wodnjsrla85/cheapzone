import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class VmMapHandler extends GetxController {
  final Completer<GoogleMapController> mapController = Completer();
  final latData = 0.0.obs;
  final longData = 0.0.obs;
  final canRun = false.obs;

  @override
  void onInit() async{
    super.onInit();
    await checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      getCurrentLocation();
    }

  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();

    latData.value = position.latitude;
    longData.value = position.longitude;
    canRun.value = true;

    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(latData.value, longData.value),
      17.0,
    ));
    
  }

  Set<Marker> get currentMarkers => {
    Marker(
      markerId: MarkerId("currentLocation"),
      position: LatLng(latData.value, longData.value),
      infoWindow: InfoWindow(title: "내 위치"),
    ),
  };

Future<List<Map<String, dynamic>>> fetchNearbyPlaces({
  required LatLng location,
  required String placeType,
  required String apiKey,
  int radius = 2000,
}) async {
  final url =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${location.latitude},${location.longitude}'
      '&radius=$radius'
      '&type=$placeType'
      '&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = data['results'] as List;

    return results.map((place) {
      final lat = place['geometry']['location']['lat'];
      final lng = place['geometry']['location']['lng'];
      final name = place['name'];
      final vicinity = place['vicinity'];

      return {
        'name': name,
        'vicinity': vicinity,
        'location': LatLng(lat, lng),
      };
    }).toList();
  } else {
    throw Exception('Places API 호출 실패: ${response.body}');
  }
}

}