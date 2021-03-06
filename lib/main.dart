import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fruit_detection/home.dart';
import 'package:get/get.dart';

List<CameraDescription>? cameras;

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras=await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Fruits Detection',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Home());
  }
}
