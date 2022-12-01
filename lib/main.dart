import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<TensorImage> getImage(Interpreter interpreter,TensorImage inputImage) async{
    var _inputShape = interpreter.getInputTensor(0).shape;
    var _outputShape = interpreter.getOutputTensor(0).shape;
    var _outputType = interpreter.getOutputTensor(0).type;
    ImageProcessor imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(
        _inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .build();
    inputImage = imageProcessor.process(inputImage);
return inputImage;
  }

  Future<void> loadModel() async {
    final interpreter = await Interpreter.fromAsset('model.tflite');
    var outputTensors=(interpreter.getOutputTensors());
    var _outputShapes = [];
    var _outputTypes = [];
    outputTensors.forEach((element) {
      _outputShapes.add(element.shape);
      _outputTypes.add(element.type);
    });
    print('Output Shapes $_outputShapes');
    // print('Output types $_outputTypes');
    final byteData = await rootBundle.load("assets/salad.jpg");
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File tempImage = File("${tempDir.path}/assets/salad.jpg")
      ..createSync(recursive: true)
      ..writeAsBytesSync(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    TensorImage inputImage = TensorImage.fromFile(tempImage);

   inputImage = await getImage(interpreter,inputImage);
      print(inputImage);
    // TensorBuffers for output tensors
    // TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);
    // TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[1]);
    // TensorBuffer outputScores = TensorBufferFloat(_outputShapes[2]);
    // TensorBuffer numLocations = TensorBufferFloat(_outputShapes[3]);
    List<Object> inputs = [inputImage.buffer];
    // Outputs map
    // Map<int, Object> outputs = {
    //   0: outputLocations.buffer,
    //   1: outputClasses.buffer,
    //   2: outputScores.buffer,
    //   3: numLocations.buffer,
    // };
    //second way....
    TensorBuffer output0 = TensorBuffer.createFixedSize(
        interpreter.getOutputTensor(0).shape,
        interpreter.getOutputTensor(0).type);
    TensorBuffer output1 = TensorBuffer.createFixedSize(
        interpreter.getOutputTensor(1).shape,
        interpreter.getOutputTensor(1).type);

    Map<int, ByteBuffer> outputs = {0: output0.buffer, 1: output1.buffer};



    // int NUM_RESULTS = 10;

   interpreter.runForMultipleInputs(inputs, outputs);
    // print(outputs);
    // // Maximum number of results to show
    // int resultsCount = min(NUM_RESULTS, numLocations.getIntValue(0));
    // print('resultsCount:$resultsCount');
    // // Using labelOffset = 1 as ??? at index 0
    // int labelOffset = 1;
    // int INPUT_SIZE = 300;
    // // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    // List<Rect> locations = BoundingBoxUtils.convert(
    //   tensor: outputLocations,
    //   valueIndex: [1, 0, 3, 2],
    //   boundingBoxAxis: 2,
    //   boundingBoxType: BoundingBoxType.BOUNDARIES,
    //   coordinateType: CoordinateType.RATIO,
    //   height: INPUT_SIZE,
    //   width: INPUT_SIZE,
    // );
    // print('location:$locations');

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

