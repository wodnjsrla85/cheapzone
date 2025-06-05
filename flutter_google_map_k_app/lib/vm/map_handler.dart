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

  final latData = 0.0.obs; //현재위치
  final longData = 0.0.obs; //현재위치

  final searchLat = 0.0.obs;
  final searchLong = 0.0.obs;

  final canRun = false.obs;
  final String apiKey = '$api'; // 실제 API 키로 교체
  final RxBool isLoading = false.obs;

  final distanceText = ''.obs;
  final durationText = ''.obs;

  final searchedPlace = ''.obs; // 검색 지명 저장
  final isSearching = false.obs; // 검색 상태 표시

  @override
  void onInit() async {
    super.onInit();
    await checkLocationPermission();
    await fetchAllTypes();
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

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
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
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(latData.value, longData.value), 17.0),
    );
  }

  //위치를 다시 불어오면 서 마카를 찍어줌
  Future<void> fetchPlacesAndMarkers({
    required String type,
    int radius = 2000,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${latData.value},${longData.value}'
      '&radius=$radius'
      '&type=$type'
      '&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load places');
    }

    final data = json.decode(response.body);
    final results = data['results'] as List;

    Set<Marker> newmarkers = {};

    for (var place in results) {
      final lat = place['geometry']['location']['lat'];
      final lng = place['geometry']['location']['lng'];
      final name = place['name'];
      final vicinity = place['vicinity'];
      final placeId = place['place_id'];

      final marker = Marker(
        markerId: MarkerId(placeId),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: name,
          snippet: vicinity,
          onTap: () {
            Get.snackbar(
              '$distanceText',
              '$durationText',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        icon: getMarkerColor(type),
        onTap: () async {
          await fetchDistanceMatrix(
            origin:
                isSearching.value == false
                    ? LatLng(latData.value, longData.value)
                    : LatLng(searchLat.value, searchLong.value),
            destination: LatLng(lat, lng),
          );
        },
      );

      newmarkers.add(marker);
    }

    // 현재 위치 마커도 추가
    newmarkers.add(
      Marker(
        markerId: MarkerId("currentLocation"),
        position: LatLng(latData.value, longData.value),
        infoWindow: InfoWindow(title: "내 위치"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    markers.value = newmarkers;
  }

  // 검색 지명으로 위치 이동
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

          searchLat.value = lat;
          searchLong.value = lng;

          final controller = await mapController.future;
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17.0),
          );

          // 검색한 위치 기준으로 주유소/주차장/충전소 다시 요청
          await fetchAllTypes();
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

  //다시 본인 위치로 돌아오는거
  Set<Marker> get currentMarkers => {
    Marker(
      markerId: MarkerId("currentLocation"),
      position: LatLng(latData.value, longData.value),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: "내 위치"),
    ),
  };

  Future<void> fetchAllTypes({int radius = 2000}) async {
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

          allMarkers.addAll(
            results.map((place) {
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
                onTap: () async {
                  await fetchDistanceMatrix(
                    origin:
                        isSearching.value == false
                            ? LatLng(latData.value, longData.value)
                            : LatLng(searchLat.value, searchLong.value),
                    destination: LatLng(lat, lng),
                  );
                },
              );
            }),
          );
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

  Future<void> fetchDistanceMatrix({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json'
      '?origins=${origin.latitude},${origin.longitude}'
      '&destinations=${destination.latitude},${destination.longitude}'
      '&mode=transit'
      '&language=ko'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['rows'][0]['elements'][0]['status'] != 'ZERO_RESULTS') {
        final distanceText = data['rows'][0]['elements'][0]['distance']['text'];
        final durationText = data['rows'][0]['elements'][0]['duration']['text']; // 예: "7분"
        print("거리: $distanceText, 소요시간: $durationText");
      } else {
        Get.snackbar('Error', '계산 데이터가 존재 하지 않습니다.');
      }
    } else {
      print('Distance Matrix API 오류: ${response.body}');
    }
  }
}
