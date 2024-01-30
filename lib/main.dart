import 'package:echo_vision/screens/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  // If Flutter needs to call native code before calling runApp
  // makes sure that you have an instance of the WidgetsBinding,
  // which is required to use platform channels to call the native code.
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  // Calls native code
  List<CameraDescription> cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo Vision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // home: const HomeScreen(),
      home: CameraScreen(cameras: cameras),
    );
  }
}
