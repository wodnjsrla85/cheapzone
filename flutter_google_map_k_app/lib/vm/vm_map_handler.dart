import 'dart:async';
import 'dart:convert';
import 'package:flutter_google_map_app/api.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class VmMapHandler extends GetxController {
  final Completer<GoogleMapController> mapController = Completer();
  final RxSet<Marker> markers = <Marker>{}.obs;
  final latData = 0.0.obs;
  final longData = 0.0.obs;
  final canRun = false.obs;
  final String apiKey = '$api'; // 실제 API 키로 교체
  final RxBool isLoading = false.obs;


  final searchedPlace = ''.obs; // 검색 지명 저장
  final isSearching = false.obs; // 검색 상태 표시

  @override
  void onInit() {
    super.onInit();
    checkLocationPermission();
  }
  //위치 허용을 하겠느냐 물어 보는 함수 
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
//gps 위치 받아옴 
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
  //위치를 다시 불어오면 서 마카를 찍어줌 
  Future<void> fetchPlaces({
    //주유소 올 등 타입
    required String placeType,
    //반경을 넣어주는 듯함
    int radius = 2000,
  }) async {
    isLoading.value = true;

    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${latData},${longData}'
        '&radius=$radius'
        '&type=$placeType'
        //위에 넣은 내 api키 
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
            icon: getMarkerColor(place),
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

  // ✅ 검색 지명으로 위치 이동
  Future<void> searchAndMoveToPlace(String place) async {
    isSearching.value = true;
    final apiKey = 'YOUR_GOOGLE_API_KEY'; // 🔑 실제 발급받은 키로 교체

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=$place&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'OK') {
          final location = jsonData['results'][0]['geometry']['location'];
          double lat = location['lat'];
          double lng = location['lng'];

          latData.value = lat;
          longData.value = lng;

          final controller = await mapController.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(lat, lng),
            17.0,
          ));
        } else {
          Get.snackbar("검색 실패", "위치를 찾을 수 없습니다");
        }
      } else {
        Get.snackbar("API 오류", "지오코딩 요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("에러", "검색 중 오류 발생: $e");
    } finally {
      isSearching.value = false;
    }
  }

  Set<Marker> get currentMarkers => {
        Marker(
          markerId: MarkerId("currentLocation"),
          position: LatLng(latData.value, longData.value),
          infoWindow: InfoWindow(title: "내 위치"),
        ),
      };

  
  Future<void> fetchAllTypes({
  int radius = 2000,
}) async {
  isLoading.value = true;
  final List<String> types = [
    'parking',
    'gas_station',
    'electric_vehicle_charging_station',
  ];

  Set<Marker> allMarkers = {};
  //타입에 맞는걸 받아 오는거 
  for (String type in types) {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${latData},${longData}'
        '&radius=$radius'
        '&type=$type'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        allMarkers.addAll(results.map((place) {
          final lat = place['geometry']['location']['lat'];
          final lng = place['geometry']['location']['lng'];
          final name = place['name'];
          final vicinity = place['vicinity'];

          return Marker(
            markerId: MarkerId('$type-$name'), // 타입별로 고유 ID
            position: LatLng(lat, lng),
            icon: getMarkerColor(type),
            infoWindow: InfoWindow(
              title: name,
              snippet: '$type | $vicinity',
            ),
          );
        }));
      }
    } catch (e) {
      Get.snackbar('에러', '[$type] 요청 실패: $e');
    }
  }

  markers.value = allMarkers;
  isLoading.value = false;
}


  
  //각 해당하는 마카를 찍어줌 
  BitmapDescriptor getMarkerColor(String type) {
  switch (type) {
    case 'parking':
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    case 'gas_station':
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    case 'electric_vehicle_charging_station':
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    default:
      return BitmapDescriptor.defaultMarker;
  }
}
}
