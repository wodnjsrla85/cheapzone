import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VmMapHandler extends GetxController {
  final Completer<GoogleMapController> mapController = Completer();
  final latData = 0.0.obs;
  final longData = 0.0.obs;
  final canRun = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLocationPermission();
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
}