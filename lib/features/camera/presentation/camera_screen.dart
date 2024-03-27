import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'camera_view.dart';

List<CameraDescription>? cameras;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;

  late Future<void> _cameraValue;

  @override
  void initState() {
    super.initState();
    _cameraValue = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(cameras[0], ResolutionPreset.high);
        await _cameraController.initialize();
      } else {
        throw 'No cameras available';
      }
    } catch (e) {
      throw 'Failed to initialize camera: $e';
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            FutureBuilder<void>(
              future: _cameraValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return CameraPreview(_cameraController);
                }
              },
            ),
            Positioned(
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.flash_off,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        GestureDetector(
                          onLongPress: () async {
                            final path = join(
                              (await getTemporaryDirectory()).path,
                              "${DateTime.now()}.mp4",
                            );
                            await _cameraController.startVideoRecording();
                          },
                          onLongPressUp: () {
                            _cameraController.stopVideoRecording();
                          },
                          onTap: () {
                            takePicture(context);
                          },
                          child: const Icon(
                            Icons.panorama_fish_eye,
                            color: Colors.white,
                            size: 70,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const Text(
                      'Hold for video, tap for photo',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void takePicture(BuildContext context) async {
    final path = join(
      (await getTemporaryDirectory()).path,
      "${DateTime.now()}.png",
    );
    XFile pictureFile = await _cameraController.takePicture();
    await pictureFile.saveTo(path);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) => CameraView(
          path: path,
        ),
      ),
    );
  }
}
