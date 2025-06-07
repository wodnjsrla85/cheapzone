import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class Detail extends StatefulWidget {
  const Detail({super.key});
  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late String productcode;
  late String productname;
  late int productDetailCode;
  late int productCode;
  late String productDescription;
  late String userId;
  List data = [];

  final box = GetStorage();
  var value = Get.arguments ?? "__";

  String selectedColor = 'Black';
  int selectedSize = 250;
  int selectedQuantity = 1;
  int quantity = 0;

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
    userId = '';
    initStorage();
    productname = value[0];
    productDetailCode = value[1];
    productDescription = value[2];
    getJSONData();
  }

  void initStorage() {
    userId = box.read('p_userId') ?? '';
  }
    getJSONData()async{
      var request = http.MultipartRequest(
      "POST",
      Uri.parse('http://127.0.0.1:8000/product/detail'),
      );
      request.fields['userid'] = userId;
      request.fields['name'] = productname;
      request.fields['size'] = selectedSize.toString();
      request.fields['color'] = colorCodeMap[selectedColor]!;
      
      var response = await request.send();
      var data = json.decode(await response.stream.bytesToString());
      print(data);
      setState(() {});
      
      if(data['results']=='Error'){
        return;
      }
      
      List results = data['results'];

      if(results.isNotEmpty){
        quantity = int.parse(results[0]['quantity']);
        productCode = results[0]['pseq'];
        print(quantity);
        print(productCode);
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(221, 230, 107, 107),
        title: Text(productname),
      ),
      body: Center(
        child: Column(
          children: [
            Image.network(
              "http://127.0.0.1:8000/product/thumbnail/$productDetailCode?t=${DateTime.now().microsecondsSinceEpoch}",
              width: 300,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  "http://127.0.0.1:8000/product/image01/$productDetailCode?t=${DateTime.now().microsecondsSinceEpoch}",
                  width: 145,
                ),
                SizedBox(width: 20),
                Image.network(
                  "http://127.0.0.1:8000/product/image02/$productDetailCode?t=${DateTime.now().microsecondsSinceEpoch}",
                  width: 145,
                ),
              ],
            ),
            Text(productname),
            Text(productDescription),
            Row(
                  children: [
                    const Text("사이즈: "),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: selectedSize,
                      dropdownColor: Colors.blue[100],
                      onChanged: (s) => setState(() {
                        selectedSize = s!;
                        getJSONData();
                      }),
                      items: fullSizeRange
                          .map((size) =>
                              DropdownMenuItem(value: size, child: Text("$size")))
                          .toList(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("색상: "),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedColor,
                      dropdownColor: Colors.blue[100],
                      onChanged: (c) => setState(() {
                        selectedColor = c!;
                        getJSONData();
                      }),
                      items: colorCodeMap.keys
                          .map((color) =>
                              DropdownMenuItem(value: color, child: Text(color)))
                          .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ignore: unnecessary_null_comparison
                if (data == null)
                  const Text("해당 색상과 사이즈 조합은 품절되었습니다.",
                      style: TextStyle(color: Colors.red)),
                // 수량 & 장바구니
                // ignore: unnecessary_null_comparison
                if (data != null)
                  Text('현재 남은 재고는 $quantity켤레 입니다.'),
                
                
                quantityDropDown(5),
                
                ElevatedButton(
                  onPressed: () {
                  if(selectedQuantity != 0){
                    insertCart();
                  }else{
                    errorSnackBar('재고가 없어서 장바구니 담기가 불가합니다.');
                  }
                  }, 
                  child: Text('장바구니에 담기'))
      
          ],
        ),
      )
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
  Widget quantityDropDown(int length){
    return DropdownButton(
      value: selectedQuantity,
      items: List.generate((quantity == 0)?length = 0 : length, (index) {
        int quantity = index +1;
        return DropdownMenuItem(
          value: quantity,
          child: Text('$quantity 결레')
          );
      },), 
      onChanged: (value) {
        if(value != null){
          selectedQuantity = value;
          setState(() {});
        }
      },
      
      );
  }
   insertCart()async{
    var request = http.MultipartRequest(
      "POST", 
      Uri.parse('http://127.0.0.1:8000/product/cart')
      );
      request.fields['pseq'] = productCode.toString();
      request.fields['userId'] = userId;
      request.fields['date'] = DateTime.now().toString();
      request.fields['buyQuantity'] = selectedQuantity.toString();
      request.fields['isCheck'] = 0.toString();
    var response = await request.send();
    var data = json.decode(await response.stream.bytesToString());
    
    if(data['result'] == 'OK'){
      updateQuantity();
      _showDialog('장바구니 담기가 완료되었습니다.');
    }else{
      errorSnackBar('문제 발생했습니다.');
    }
  }
  updateQuantity()async{
    var request = http.MultipartRequest(
      "POST", 
      Uri.parse('http://127.0.0.1:8000/product/updateQuantity')
      );
      int item = quantity - selectedQuantity;
      print('차익 : $item');
      request.fields['quantity'] = item.toString();
      request.fields['seq'] = productCode.toString();

       try {
    var response = await request.send();
    var data = json.decode(await response.stream.bytesToString());

    print('응답 결과: $data');

    if (data['result'] == 'OK') {
      print('✅ 수량 업데이트 성공');
    } else {
      print('❌ 수량 업데이트 실패: ${data['result']}');
    }
  } catch (e) {
    print('🛑 예외 발생: $e');
  }
  }


  _showDialog(String message) {
    Get.defaultDialog(
      title: '환영합니다.',
      middleText: message,
      backgroundColor: Colors.blue,
      barrierDismissible: false,
      actions: [
        TextButton.icon(
          icon: Icon(Icons.check),
          onPressed: () {
            Get.back(); // 다이얼로그 지움
          },
          label: Text('확인'),
        ),
      ],
    );
  }
}