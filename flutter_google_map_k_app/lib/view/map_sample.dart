/**
 * 2025 6월 02일,06월 03 
 * 개발일지 : 본인 api키로 구글 맵을 띄우고 공공 api키를 받아 주유소 위치를 마카로 찍었다. 
 * 개발자  : 전종익 
 * 2025월 6월 04일 
 * 개발일지 : 본인 api키가 있으면 구글 지명 검색으로 지도를 띄우는걸 만들었다. 
 * 개발자 : 김수아 
 * 
 * 2025 6월 04 
 * 개발일지 : 본인 api가 있으면 구글에서 부터 주유소 주차장 충전소 위치를 받아 색을 다르게 마카를 찍었다. 
 * 개발자 : 김재원
 */
import 'package:flutter/material.dart';
import 'package:flutter_google_map_app/api.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice2/places.dart';
import '../vm/vm_map_handler.dart';

class MapSample extends StatelessWidget {
  MapSample({super.key});

  final searchController = TextEditingController();
  //본인 구글 키 여기에 넣어야해요!
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey:'$api');
  


  @override
  Widget build(BuildContext context) {
    final vm = Get.find<VmMapHandler>();
    final VmMapHandler vmhandler = Get.put(VmMapHandler());
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 위치 지도"),
         actions: [
          PopupMenuButton<String>(
            onSelected: (type) {
              type != 'all'
                  ? vmhandler.fetchPlaces( placeType: type)
                  : vmhandler.fetchAllTypes();
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: '장소, 가게, 건물 검색',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    final query = searchController.text;
                    if (query.isEmpty) return;

                    final response = await _places.searchByText(query, language: 'ko', region: 'kr');
                    if (response.status == 'OK' && response.results.isNotEmpty) {
                      final result = response.results.first;
                      final lat = result.geometry!.location.lat;
                      final lng = result.geometry!.location.lng;

                      final controller = await vm.mapController.future;
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
                      );
                    } else {
                      Get.snackbar('검색 실패', '검색 결과가 없습니다.');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (!vm.canRun.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return GoogleMap(
          
             initialCameraPosition: CameraPosition( target: LatLng(vmhandler.latData.value, vmhandler.longData.value),zoom: 14,),
              markers: vmhandler.markers.toSet(),
            );
      }),
    );
  }
}

