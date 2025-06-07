import 'dart:convert';
import 'package:flutter_google_map_app/model/inquiry_query.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VmInquiryHandler extends GetxController {
  final String baseUrl = "http://127.0.0.1:8000";
  // final RxList<InquiryQuery> inquiryQuery = <InquiryQuery>[].obs;


  /// 서버에서 받은 모든 데이터를 저장하는 원본 리스트
  final List<InquiryQuery> _allInquiries = [];
  // 화면에 실제로 보여줄 필터링된 리스트
  final RxList<InquiryQuery> filteredInquiries = <InquiryQuery>[].obs;

  final RxBool isLoading = false.obs; // 데이터 로딩 상태 (true이면 로딩 중)
  final RxnString error = RxnString(); // 오류 메시지 저장 (null일 수 있음)

  final List<String> items = ['전체보기', '주유소', '전기차 충전소', '주차장', '답변완료', '진행중'];
  late RxString dropDownValue;

  @override
  void onInit() {
    super.onInit();
    dropDownValue = items[0].obs; //첫 번째 아이템으로 초기화
    fetchInquiry();
  }



  // 드롭다운 메뉴의 값이 변경될 때 호출되는 함수
  void updateDropdownValue(String? newValue) {
    if (newValue != null) {
      dropDownValue.value = newValue; // 선택된 값 업데이트

      // `.where()`는 조건에 맞는 항목만 골라내는 강력한 기능.
      switch (newValue) {
        case '전체보기':
          filteredInquiries.assignAll(_allInquiries);
          break;
        //다른건 왜 안뜰까요?
        // case '주유소':
        //   var filteredList = _allInquiries.where((inquiry) => inquiry.category == 1).toList();
        //   filteredInquiries.assignAll(filteredList);
        //   break;
        // case '전기차 충전소':
        //   var filteredList = _allInquiries.where((inquiry) => inquiry.category == 1).toList();
        //   filteredInquiries.assignAll(filteredList);
        //   break;
        // case '주차장':
        //   var filteredList = _allInquiries.where((inquiry) => inquiry.category == 1).toList();
        //   filteredInquiries.assignAll(filteredList);
        //   break;
        case '답변완료':
          // status가 1인(답변완료) 항목만 필터링합니다.
          var filteredList =
              _allInquiries.where((inquiry) => inquiry.status == 1).toList();
          filteredInquiries.assignAll(filteredList);
          break;

        case '진행중':
          var filteredList =
              _allInquiries.where((inquiry) => inquiry.status == 0).toList();
          filteredInquiries.assignAll(filteredList);
          break;

        default:
          // '주유소', '전기차 충전소' 등은 카테고리로 필터링
          // inquiry의 category(문자열)와 선택된 newValue(문자열)를 비교합니다.
          var filteredList =
              _allInquiries
                  .where((inquiry) => inquiry.category == newValue)
                  .toList();
          filteredInquiries.assignAll(filteredList);
          break;
      }
    }
  }




  // 서버에서 문의 목록 가져오는 비동기 함수
  Future<void> fetchInquiry() async {
    try {
      isLoading.value = true;
      _allInquiries.clear();
      final res = await http.get(Uri.parse("$baseUrl/inquiry/select"));
      final data = json.decode(utf8.decode(res.bodyBytes));
      final List results = data['results'];

      final List<InquiryQuery> returnResult =
          results.map((data) {
            return InquiryQuery(
              id: data[0],
              date: data[1],
              type: data[2],
              content: data[3],
              category: data[4],
              status: data[5],
              userEmail: data[6], // ?? '__' ;
            );
          }).toList();

      _allInquiries.clear();
      _allInquiries.addAll(returnResult);
      filteredInquiries.assignAll(_allInquiries);
    } catch (e) {
      error.value = "불러오기 실패 : $e";
    } finally {
      isLoading.value = false;
    }
  }
}
