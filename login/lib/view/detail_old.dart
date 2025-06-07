import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shoe_team_project/model/basket.dart';
import 'package:shoe_team_project/model/productDetail.dart';
import 'package:shoe_team_project/view_model/database_handler.dart';

class Detail extends StatefulWidget {
  const Detail({super.key});
  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late DatabaseHandler handler;
  late String productcode;
  late String productname;
  late String userId;

  final box = GetStorage();
  var value = Get.arguments ?? "__";

  String selectedColor = 'Black';
  int selectedSize = 250;
  int selectedQuantity = 1;
  int maxQuantity = 0;
  ProductDetail? selectedProduct;
  List<ProductDetail> allData = [];

  final Map<String, String> colorCodeMap = {
    'Black': '20',
    'White': '21',
    'Red': '22',
    'Grey': '23',
    'Blue': '24',
  };
  final List<int> fullSizeRange = [220, 230, 240, 250, 260, 270, 280, 290, 300];

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    userId = '';
    initStorage();
    if (value is List && (value as List).length >= 2) {
      productcode = (value as List)[0];
      productname = (value as List)[1];
      print('▶ Detail init: code=$productcode, name=$productname');
    } else {
      Get.back();
    }
  }

  void initStorage() {
    userId = box.read('p_userId') ?? '';
  }

  void updateSelectedProduct() {
    final code = colorCodeMap[selectedColor]!;
    // 매칭되는 Variant 찾기
    final matches = allData.where((e) =>
      e.color.toString() == code && e.size == selectedSize
    ).toList();
    if (matches.isNotEmpty) {
      selectedProduct = matches.first;
      maxQuantity = selectedProduct!.quantity;
      if (selectedQuantity > maxQuantity) selectedQuantity = 1;
    } else {
      selectedProduct = null;
      maxQuantity = 0;
      selectedQuantity = 1;
    }
    print('▶ Updated: $selectedColor/$selectedSize -> '
      '${selectedProduct != null ? 'FOUND' : 'NOT FOUND'}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(221, 230, 107, 107),
        title: Text(productname),
      ),
      body: FutureBuilder<List<ProductDetail>>(
        future: handler.queryImageregister(productname),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('로딩 중 에러: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(child: Text("상품 정보를 불러올 수 없습니다."));
          }
          allData = data;
          print('▶ Loaded variants: ${allData.length}');
          // 첫 빌드 때 기본 선정
          if (selectedProduct == null) {
            selectedColor = colorCodeMap.entries
                .firstWhere((e) => e.value == allData.first.color.toString(),
                    orElse: () => const MapEntry('Black', '20'))
                .key;
            selectedSize = allData.first.size;
          }
          updateSelectedProduct();
          final display = selectedProduct ?? allData.first;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 대표 이미지
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(display.image, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                // 썸네일
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            Image.memory(display.image01, height: 120, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            Image.memory(display.image02, height: 120, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(productname,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("설명: ${display.description}"),
                const SizedBox(height: 10),
                Text("가격: ${display.price}원"),
                const SizedBox(height: 20),

                // 색상 선택
                Row(
                  children: [
                    const Text("색상: "),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedColor,
                      dropdownColor: Colors.blue[100],
                      onChanged: (c) => setState(() {
                        selectedColor = c!;
                        updateSelectedProduct();
                      }),
                      items: colorCodeMap.keys
                          .map((color) =>
                              DropdownMenuItem(value: color, child: Text(color)))
                          .toList(),
                    ),
                  ],
                ),

                // 사이즈 선택
                Row(
                  children: [
                    const Text("사이즈: "),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: selectedSize,
                      dropdownColor: Colors.blue[100],
                      onChanged: (s) => setState(() {
                        selectedSize = s!;
                        updateSelectedProduct();
                      }),
                      items: fullSizeRange
                          .map((size) =>
                              DropdownMenuItem(value: size, child: Text("$size")))
                          .toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                if (selectedProduct == null)
                  const Text("해당 색상과 사이즈 조합은 품절되었습니다.",
                      style: TextStyle(color: Colors.red)),

                // 수량 & 장바구니
                if (selectedProduct != null && maxQuantity > 0) ...[
                  Row(
                    children: [
                      const Text("수량: "),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                        value: selectedQuantity,
                        dropdownColor: Colors.blue[100],
                        onChanged: (q) => setState(() => selectedQuantity = q!),
                        items: List.generate(maxQuantity, (i) => i + 1)
                            .map((qty) =>
                                DropdownMenuItem(value: qty, child: Text("$qty")))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('장바구니에 담기'),
                      onPressed: () async {
                        final basket = Basket(
                          productCode: display.productCode,
                          buyProductName:
                              '${display.productName}\n색상: $selectedColor | 사이즈: $selectedSize',
                          buyProductPrice: display.price,
                          buyProductQuantity: selectedQuantity,
                          userid: userId,
                          image: display.image,
                          ischeck: 0,
                        );
                        final res = await handler.insertBasket(basket);
                        if (res != 0) {
                          Get.defaultDialog(
                            title: '',
                            middleText: '장바구니에 담았습니다.',
                            textConfirm: '확인',
                            backgroundColor:
                                const Color.fromARGB(221, 230, 107, 107),
                            onConfirm: () {
                              Get.back();
                              Get.back();
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(221, 230, 107, 107),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}