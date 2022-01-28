import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'edit_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              // Pick an image
              final XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (image == null) return;
              final croppedFile = await Navigator.of(context).push<File>(
                  MaterialPageRoute(
                      builder: (ctx) => EditeImage(File(image.path))));
            },
            child: const Text("Prendre une image"),
          ),
        ),
      ),
    );
  }
}
