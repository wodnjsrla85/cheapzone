import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_model/database_handler.dart';
import 'package:http/http.dart' as http;

import 'detail.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DatabaseHandler handler;
  List<int> selectedIndexes = [];
  late TextEditingController search;
  List data = [];
  late String keyword;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    search = TextEditingController();
    handler.insertInitialStores();
    
    getJSONData();
  }

  getJSONData()async{
    keyword = search.text.trim();
    var response = await http.get(Uri.parse("http://127.0.0.1:8000/product/display?keyword=$keyword"));

    if(response.statusCode == 200){
      data.clear();
      data.addAll(json.decode(utf8.decode(response.bodyBytes))['results']);
      print(data);
      setState(() {});
    }else{
      errorSnackBar('서버 오류: ${response.statusCode}');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("상품내역"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(221, 230, 107, 107),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: search,
              decoration: InputDecoration(
                hintText: "상품명 검색",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                getJSONData();
                setState(() {}); // 변경 사항 반영
              },
            ),
          ),
          Expanded(
            child: data.isEmpty
            ? Center(child: Text('데이터가 없습니다.'))
            : GridView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        () => Detail(),
                        arguments: [
                          data[index]['name'],
                          data[index]['code'],
                          data[index]['description']
                        ]
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                        '${data[index]['thumbnail']}',
                        height: 200,
                        ),
                        Text('모델명: ${data[index]['name']}'),
                        Text('가격: ${data[index]['price']}원')
                      ],
                    ),
                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.75,
                ),
              ),
          )



          // Expanded(
          //   child: FutureBuilder(
          //     future: handler.queryProductsearch(search.text),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const Center(child: CircularProgressIndicator());
          //       }
          //       if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          //         return GridView.builder(
          //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //           itemCount: snapshot.data!.length,
          //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //             crossAxisCount: 2,
          //             crossAxisSpacing: 12,
          //             mainAxisSpacing: 12,
          //             childAspectRatio: 0.75,
          //           ),
          //           itemBuilder: (context, index) {
          //             final product = snapshot.data![index];
          //             return GestureDetector(
          //               onTap: () {
          //                 Get.to(
          //                   Detail(),
          //                   arguments: [
          //                     product.productCode,
          //                     product.productName,
          //                   ],
          //                 );
          //               },
          //               child: Material(
          //                 elevation: 4,
          //                 borderRadius: BorderRadius.circular(12),
          //                 child: Container(
          //                   decoration: BoxDecoration(
          //                     borderRadius: BorderRadius.circular(12),
          //                     color: Colors.white,
          //                   ),
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.center,
          //                     children: [
          //                       ClipRRect(
          //                         borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          //                         child: Image.memory(
          //                           product.image!,
          //                           height: 150,
          //                           width: double.infinity,
          //                           fit: BoxFit.cover,
          //                         ),
          //                       ),
          //                       Padding(
          //                         padding: const EdgeInsets.all(8.0),
          //                         child: Column(
          //                           children: [
          //                             Text(
          //                               product.productName,
          //                               style: const TextStyle(
          //                                 fontWeight: FontWeight.w600,
          //                                 fontSize: 16,
          //                               ),
          //                               maxLines: 1,
          //                               overflow: TextOverflow.ellipsis,
          //                             ),
          //                             const SizedBox(height: 4),
          //                             Text(
          //                               "${product.price}원",
          //                               style: const TextStyle(
          //                                 color: Colors.redAccent,
          //                                 fontWeight: FontWeight.bold,
          //                                 fontSize: 14,
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //         );
          //       } else {
          //         return const Center(
          //           child: Text(
          //             "검색 결과가 없습니다.",
          //             style: TextStyle(fontSize: 16, color: Colors.grey),
          //           ),
          //         );
          //       }
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
  errorSnackBar(String message) {
    Get.snackbar(
      '경고',
      message,
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
      colorText: Colors.white,
      backgroundColor: Colors.red,
    );
  }
}