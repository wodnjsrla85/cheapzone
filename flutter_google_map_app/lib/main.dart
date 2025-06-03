import 'package:flutter/material.dart';
import 'package:flutter_google_map_app/view/map_sample.dart';
import 'package:flutter_google_map_app/vm/vm_map_handler.dart';
import 'package:get/get.dart';

void main() {
  Get.put(VmMapHandler());
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
      ),
      home: const MapSample(),
    );
  }
}