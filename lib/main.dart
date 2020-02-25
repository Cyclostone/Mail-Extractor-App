import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'image_detail.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) exit(1);
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Kit Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Mail Extractor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraController _controller;

  void initstate() {
    super.initState();

    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _takePicturesPressed() {
    _takePicture().then((String filepath) {
      if (mounted) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ImageDetail(filepath)));
      }
    });
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String photoDir = '${extDir.path}/Photos/image_test';
    await Directory(photoDir).create(recursive: true);
    final String filePath = '$photoDir/${timestamp()}.jpg';

    if (_controller.value.isTakingPicture) {
      print("Currently already taking Picture");
      return null;
    }

    try {
      await _controller.takePicture(filePath);
    } on CameraException catch (e) {
      print("camera exception occured: $e");
      return null;
    }

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(
        child: Text("Controller is not Intialized!"),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: RaisedButton.icon(
                    icon: Icon(Icons.camera),
                    label: Text("Take a Picture"),
                    onPressed: _takePicturesPressed,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
