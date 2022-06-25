import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'main.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isWorking = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? imgCamera;

  initCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController!.startImageStream((image) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = image,
                  runModelOnStreamFrames()
                }
            });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/modelfruits.tflite',
      labels: 'assets/labelsfruits.txt',
    );
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    loadModel();
  }

  @override
  void dispose() async {
    // ignore: todo
    // TODO: implement dispose
    super.dispose();

    await Tflite.close();
    cameraController?.dispose();
  }

  runModelOnStreamFrames() async {
    var recognition = await Tflite.runModelOnFrame(
      bytesList: imgCamera!.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: imgCamera!.height,
      imageWidth: imgCamera!.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResults: 2,
      threshold: 0.1,
      asynch: true,
    );
    result = '';
    for (var response in recognition!) {
      result += response['label'] +
          ' ' +
          (response['confidence'] as double).toStringAsFixed(2) +
          '\n\n';
    }

    setState(() {
      result;
    });
    isWorking = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(title: const Text('Fruits Detector'),backgroundColor:Colors.redAccent, centerTitle: true,),
      body:Container(decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/backgrounds.jpg'),fit:BoxFit.fill)
      ),
      child:Column(
        children: [
          Stack(
            children: [
              Center(child: Container(
                margin:const EdgeInsets.only(top:100.0),
                height:220,
                width:320,
                child:Image.asset("assets/frames.jpg")
                ),
              ),

              Center(
                child: TextButton(onPressed: () {
                initCamera();
                },
                child:Container(
                  margin:const EdgeInsets.only(top:65.0), height:270,
                  width:360,
                  child:imgCamera==null ?
                  const SizedBox(
                    height:270,
                    width:360,
                    child:Icon(Icons.photo_camera_front, color:Colors.pink, size:60.0,),)
                  : AspectRatio(aspectRatio: cameraController!.value.aspectRatio,
                      child:CameraPreview(cameraController!),
                    ),
                  ),
                ),
              )            
            ],
          ),
          Center(
            child:Container(
              margin:const EdgeInsets.only(top:55.0),
              child:SingleChildScrollView(
                child:Text(
                  result,
                  style:const TextStyle(
                    backgroundColor:Colors.black87,
                    fontSize:25.0,  
                    color:Colors.white
                  ),
                  textAlign:TextAlign.center,
                ),
              )
            )
          )
        ],
    
      )
    )
    ));
  }
}
