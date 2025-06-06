/**
 * 2025 6월 02일,06월 03 
 * 개발일지 : 본인 api키로 구글 맵을 띄우고 공공 api키를 받아 주유소 위치를 마카로 찍었다. 
 * 개발자  : 전종익 
 * 
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
import 'package:flutter_google_map_app/view/inquiry_query.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice2/places.dart';
import '../vm/vm_map_handler.dart';

class MapSample extends StatelessWidget {
  MapSample({super.key});

  final searchController = TextEditingController();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: api); // api는 문자열 키
  final List<String> buttonText = ['모두보기', '주차장', '주유소', '전기차 충전소'];
  @override
  Widget build(BuildContext context) {
    final vm = Get.find<VmMapHandler>();
    return Obx(() {
      return Scaffold(
        body:
            !vm.canRun.value
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                  children: [
                    // 기본 구글 맵
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(vm.latData.value, vm.longData.value),
                        zoom: 14,
                      ),
                      markers: vm.markers.toSet(),
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) {
                        if (!vm.mapController.isCompleted) {
                          vm.mapController.complete(controller);
                        }
                      },
                    ),

                    // 내위치, 북마크, 문의하기 버튼
                    Positioned(
                      left: 28,
                      bottom: vm.bottomButtonsPosition.value,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 226.0),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () async {
                                  vm.isSearching.value = true;
                                  vm.fetchAllTypes();
                                  final controller =
                                      await vm.mapController.future;
                                  controller.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(
                                        vm.latData.value,
                                        vm.longData.value,
                                      ),
                                      17.0,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.white,
                                ),
                                child: Icon(
                                  Icons.my_location,
                                  size: 40,
                                  color: Color(0xff0E5A9D),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 18.0),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => InquiryQuery());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Colors.white,
                                    ),
                                    child: Icon(
                                      Icons.bookmark_added,
                                      size: 40,
                                      color: Color(0xffFFAB17),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => InquiryQuery());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Icon(
                                    Icons.question_answer,
                                    size: 40,
                                    color: Color(0xff0E5A9D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    vm.bottomContainerHeight.value > 110
                        ? Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              vm.markClicked.value = false;
                              vm.bottomContainerHeight.value = 110.0;
                              vm.bottomButtonsPosition.value =
                                  vm.bottomContainerHeight.value + 20;
                            },
                            child: Container(color: Colors.transparent),
                          ),
                        )
                        : const SizedBox.shrink(),

                    // 하단 컨테이너
                    Positioned(
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: vm.bottomContainerHeight.value,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: SizedBox(
                                  width: 50,
                                  height: 5, // 두께
                                  child: GestureDetector(
                                    onVerticalDragUpdate: (details) {
                                      vm.bottomContainerHeight.value -=
                                          details.delta.dy;
                                      // 하단 막대를 올리면 올라가고 내리면 내려가게
                                      vm.bottomContainerHeight.value = vm
                                          .bottomContainerHeight
                                          .value
                                          .clamp(110.0, 425.0);
                                      // 최대.최소 높이 지정
                                      vm.bottomButtonsPosition.value =
                                          vm.bottomContainerHeight.value + 20;
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xff0E5A9D),
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ), // 양끝 둥글게
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: vm.markClicked.value,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    28,
                                    20,
                                    28,
                                    0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vm.placeName.value,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24,
                                          color: Colors.black,
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          0,
                                          10,
                                          0,
                                          10,
                                        ),
                                        child: Text(
                                          '평점 : ${vm.placeRating.value}     리뷰 개수 : ${vm.placeRatingCount.value}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            color: Color(0xff6F7D8E),
                                          ),
                                        ),
                                      ),

                                      Text(
                                        '주소 : ${vm.placeAddress.value}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                          color: Color(0xff6F7D8E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          0,
                                          10,
                                          0,
                                          10,
                                        ),
                                        child: Text(
                                          '전화번호 : ${vm.placePhone}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            color: Color(0xff6F7D8E),
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 101.0,
                                        ),
                                        child: Text(
                                          '운영시간 : ${vm.placeTime}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            color: Color(0xff6F7D8E),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        width: 346,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xff3F51B5),
                                          ),
                                          child: Text(
                                            '저장하기',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 장소 검색 Textfield
                    Positioned(
                      top: 60,
                      left: 28,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.zero,
                          width: MediaQuery.of(context).size.width - 56,
                          height: 60,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 12, 0, 0),
                            child: TextField(
                              controller: searchController,
                              onSubmitted: (_) async {
                                final query = searchController.text.trim();
                                if (query.isEmpty) return;
                                final response = await _places.searchByText(
                                  query,
                                  language: 'ko',
                                  region: 'kr',
                                );
                                if (response.status == 'OK' &&
                                    response.results.isNotEmpty) {
                                  final result = response.results.first;
                                  final lat = result.geometry!.location.lat;
                                  final lng = result.geometry!.location.lng;
                                  final controller =
                                      await vm.mapController.future;
                                  controller.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      LatLng(lat, lng),
                                      17,
                                    ),
                                  );

                                  vm.searchLat.value = lat;
                                  vm.searchLong.value = lng;
                                  await vm.fetchAllTypes();
                                } else {
                                  Get.snackbar('검색 실패', '검색 결과가 없습니다.');
                                }
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none, // 기본 밑줄 제거
                                enabledBorder: InputBorder.none, // 비활성 상태 밑줄 제거
                                focusedBorder: InputBorder.none, // 포커스 상태 밑줄 제거
                                hintText: '장소 검색',
                                hintStyle: TextStyle(
                                  color: Color(0xffB9B9B9),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                ), // 수직 패딩 제거
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Icon(
                                    Icons.search,
                                    size: 30,
                                    color: Color(0xffB9B9B9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 카테고리 선택 버튼들
                    Positioned(
                      top: 135,
                      right: 28,
                      child: SizedBox(
                        width: 300,
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: buttonText.length,
                          itemBuilder: (context, index) {
                            final text = buttonText[index];
                            return ElevatedButton(
                              onPressed: () {
                                switch (text) {
                                  case '모두보기':
                                    vm.fetchAllTypes();
                                  case '주차장':
                                    vm.fetchPlacesAndMarkers(type: 'parking');
                                  case '주유소':
                                    vm.fetchPlacesAndMarkers(
                                      type: 'gas_station',
                                    );
                                  case '전기차 충전소':
                                    vm.fetchPlacesAndMarkers(
                                      type: 'electric_vehicle_charging_station',
                                    );
                                }
                                vm.isSelected.value = text;
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                buttonText[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      vm.isSelected.value == text
                                          ? Color(0xff0F599D)
                                          : Color(0xffB9B9B9),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      );
    });
  }
}
