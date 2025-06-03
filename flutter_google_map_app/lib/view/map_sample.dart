import 'package:flutter/material.dart';
import 'package:flutter_google_map_app/vm/vm_map_handler.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapSample extends StatelessWidget {
  const MapSample({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<VmMapHandler>();

    return Scaffold(
      appBar: AppBar(title: Text("내 위치 지도")),
      body: Obx(() {
        if (!vm.canRun.value) {
          return Center(child: CircularProgressIndicator());
        }

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(vm.latData.value, vm.longData.value),
            zoom: 17,
          ),
          onMapCreated: (GoogleMapController controller) {
            vm.mapController.complete(controller);
          },
          markers: vm.currentMarkers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
        );
      }),
    );
  }
}