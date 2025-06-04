import 'package:flutter/material.dart';
import 'package:flutter_google_map_app/vm/places_controller.dart';
import 'package:flutter_google_map_app/vm/vm_map_handler.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatelessWidget {
  const MapSample({super.key});

  @override
  Widget build(BuildContext context) {
    final mapController = Get.put(VmMapHandler());
    final PlacesController controller = Get.put(PlacesController());
    LatLng center = LatLng(37.4979, 127.0276); // 강남역 인근

    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 시설 검색'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (type) {
              type != 'all'
                  ? controller.fetchPlaces(location: center, placeType: type)
                  : controller.fetchAllTypes(location: center);
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'all', child: Text('모두 보기')),
                  const PopupMenuItem(value: 'parking', child: Text('주차장')),
                  const PopupMenuItem(value: 'gas_station', child: Text('주유소')),
                  const PopupMenuItem(
                    value: 'electric_vehicle_charging_station',
                    child: Text('전기차 충전소'),
                  ),
                ],
          ),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: center, zoom: 14),
              markers: controller.markers.toSet(),
            ),
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
