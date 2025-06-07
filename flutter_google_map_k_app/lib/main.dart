import 'package:flutter/material.dart';
import 'package:flutter_google_map_app/view/map_home.dart';
import 'package:flutter_google_map_app/vm/vm_inquiry_handler.dart';
import 'package:flutter_google_map_app/vm/vm_map_handler.dart';
import 'package:get/get.dart';

void main() {
  Get.put(VmMapHandler());
  Get.put(VmInquiryHandler());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Pretendard'
      ),
      home:  MapSample(),
    );
  }
}