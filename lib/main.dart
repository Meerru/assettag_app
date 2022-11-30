import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  Future<void> getImage() async{

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    //File image = File('$tempPath/assets/bus.jpg');

    print(tempPath);

    // ImageProcessor imageProcessor = ImageProcessorBuilder()
    //     .add(ResizeOp(224, 224, ResizeMethod.NEAREST_NEIGHBOUR))
    //     .build();
    //
    // TensorImage tensorImage = TensorImage.fromFile(File(image!.path));
    // print(tensorImage);

    //inputImage = imageProcessor.process(inputImage);
  }

  Future<void> loadModel() async {
    final interpreter = await Interpreter.fromAsset('tflite-416-fp32.tflite');
    var outputTensors=(interpreter.getOutputTensors());
    var _outputShapes = [];
    var _outputTypes = [];
    outputTensors.forEach((element) {
      _outputShapes.add(element.shape);
      _outputTypes.add(element.type);
    });
    print('Output Shapes $_outputShapes');
    print('Output types $_outputTypes');
    getImage();
  }
    @override
    Widget build(BuildContext context) {
      return Container(
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          ),
          onPressed: () {
            loadModel();
          },
          child: Text('TextButton'),
        ),
      );
    }
}

