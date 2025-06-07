import 'package:flutter/material.dart';
import 'package:flutter_google_map_app/view/insert_inquiry.dart';
import 'package:flutter_google_map_app/vm/vm_inquiry_handler.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';

class InquiryQuery extends StatelessWidget {
  const InquiryQuery({super.key});

  @override
  Widget build(BuildContext context) {
    final VmInquiryHandler vmHandler = Get.find<VmInquiryHandler>();

    return Scaffold(
      body: Obx(() {
        return Column(
          children: [
            SizedBox(height: 100), // 상단 여백
            // 상단
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Get.back(), //뒤로가기
                    icon: Icon(Icons.arrow_back_ios_new_outlined, size: 34),
                  ),
                  Text(
                    '문의 게시판',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '문의 개수: ${vmHandler.filteredInquiries.length} 개',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton(
                    dropdownColor: Colors.white,
                    iconEnabledColor: Colors.black,
                    value: vmHandler.dropDownValue.value,
                    icon: Icon(Icons.keyboard_arrow_down),
                    items:
                        vmHandler.items.map((String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(color: Color(0xff3F51B5)),
                            ),
                          );
                        }).toList(),
                    onChanged: vmHandler.updateDropdownValue,
                  ),
                ],
              ),
            ),
            //문의 목록 리스트
            Expanded(
              child: ListView.builder(
                itemCount: vmHandler.filteredInquiries.length,
                itemBuilder: (context, index) {
                  // 현재 인덱스에 해당하는 문의 데이터
                  final inquiry = vmHandler.filteredInquiries[index];

                  //isAnswered는 true, false가 status 값이 숫자 1이면 됩니다.
                  bool isAnswered = inquiry.status == 1;

                  // 답변 상태에 따라 다른 색상 지정
                  Color statusColor =
                      isAnswered
                          ? const Color(0xFF4A5C9D) // 답변완료: 푸른색
                          : Colors.green; // 진행중: 초록색

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 0,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: statusColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${inquiry.date}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('${inquiry.content}'),
                              ],
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                isAnswered ? '답변완료' : '진행중',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            //문의 작성 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff3F51B5),
                minimumSize: Size(340, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                //작성페이지 이동
                Get.to(() => InsertInquiry());
              },
              child: Text(
                '문의 작성',
                style: TextStyle(
                  fontSize: 21,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
